import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:mary/constants/constants.dart';
import 'package:mary/models/conversation.dart';
import 'package:mary/models/patient.dart';
import 'package:mary/providers/mary_chat_provider.dart';
import 'package:mary/routing/router.dart';
import 'package:mary/routing/routes.dart';
import 'package:mary/services/api_service_provider.dart';
import 'package:mary/style/style.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:developer' as dev;

class ChatNotifier extends ChangeNotifier {
  bool isRecording = false;
  bool isAvailable = false;
  bool waitingForResponse = false;
  bool isLoading = false;
  String? error;
  String? maryQuery;
  String? patientId;
  String? sessionId;
  String? maryResponse;
  Conversation conversation = Conversation([]);
  // List<Patient> patients = <Patient>[];
  // ChatData? prevChatData;
  // Conversation? previousConversation;

  late FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;

  final SpeechToText _speechToText = SpeechToText();

  initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
  }

  marySpeak(String textToSpeak) {
    flutterTts.speak(textToSpeak);
  }

  maryStopSpeaking() async {
    try {
      await flutterTts.stop();
    } catch (e) {
      dev.log(e.toString(), name: "maryStopSpeaking > error");
    }
  }

  startRecording() {
    isRecording = true;
    notifyListeners();
    if (isAvailable) {
      _speechToText.listen(
        onResult: (val) {
          dev.log(val.recognizedWords, name: "recognized Words >>> ");
          maryQuery = val.recognizedWords;
          notifyListeners();
        },
      );
    }
  }

  stopRecording({bool isPreviousChat = false}) {
    isRecording = false;
    notifyListeners();
    _speechToText.stop();
    if (maryQuery?.isNotEmpty ?? false) {
      dev.log('calling sendQuery with >$maryQuery<');
      if ((maryQuery ?? "").isNotEmpty) {
        sendQuery(maryQuery ?? "", speak: true);
      }
    }
  }

  sendQuery(
    String query, {
    bool speak = false,
    bool isPreviousChat = false,
  }) async {
    //api call for query
    Map<String, String> queryParamsBody = <String, String>{
      "access_token": AppConstants().meldRxAccessToken ?? "",
      "query": query,
    };

    if (sessionId != null) {
      queryParamsBody["session_id"] = sessionId ?? "";
    }

    if (patientId != null) {
      queryParamsBody["patient_id"] = patientId ?? "";
    }

    String queryParams = Uri(queryParameters: queryParamsBody).query;

    waitingForResponse = true;
    notifyListeners();

    Map<String, dynamic> response = await ApiService().postRequest(
      '?$queryParams',
    );

    // Map<String, dynamic> response = {
    //   "success": false,
    //   "error": "Unable to process patient information request.",
    // };

    handleResponse(response, speak: speak);

    if (speak) {
      marySpeak(maryResponse ?? "");
    }
  }

  addQuery(String q, {bool isPreviousChat = false}) {
    ConversationPiece cp = ConversationPiece(
      role: ConversationRole.user,
      content: q,
    );
    conversation.data.add(cp);
    notifyListeners();
  }

  handleResponse(Map<String, dynamic> res, {bool speak = false}) async {
    try {
      if (res.containsKey("error")) {
        conversation.data.add(
          ConversationPiece(
            role: ConversationRole.assistant,
            content: res['error'],
          ),
        );
        waitingForResponse = false;
        notifyListeners();
        if (speak) {
          marySpeak(res["error"]);
        }
        return;
      }

      if (res.containsKey("response") &&
          res["response"] == "Token has expired, please regenerate.") {
        ScaffoldMessenger.of(navKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text("Token Expired", style: MaryStyle().white14w400),
            backgroundColor: Colors.red,
          ),
        );
        // navigateTo(MaryAppRoutes.meldRxLogin);
        return;
      }

      MaryChatData newData = MaryChatData.fromJSON(res);

      waitingForResponse = false;
      // maryQuery = newData.query ?? maryQuery;
      maryResponse =
          res.containsKey("response") ? res["response"] : maryResponse;
      // maryResponse = newData.response;

      patientId = res.containsKey("patient_id") ? res["patient_id"] : patientId;

      sessionId = res.containsKey("session_id") ? res["session_id"] : sessionId;

      conversation =
          res.containsKey("conversation")
              ? Conversation.fromJSON(res["conversation"])
              : maryResponse != null
              ? Conversation([
                ...conversation.data,
                ConversationPiece(
                  role: ConversationRole.assistant,
                  content: maryResponse!,
                ),
              ])
              : Conversation([]);

      if (res.containsKey("requires_selection")) {
        if (res.containsKey("patients")) {
          List<Patient> patients =
              res["patients"]
                  .map((e) => Patient.fromJSON(e))
                  .toList()
                  .cast<Patient>();

          showPatientSelectionDialog(patients).then((patientID) {
            dev.log("$patientID", name: "showPatientSelectionDialog");
            if (patientID != null) {
              patientId = patientID;
              notifyListeners();
            }
          });
        }
      }
      notifyListeners();
      //queryResponse
    } catch (e) {
      dev.log(e.toString(), name: "handle response error");
      error = e.toString();
      notifyListeners();
    }
  }

  f() {
    dev.log(conversation.data.length.toString(), name: "conversation length");
    // dev.log(maryQuery.toString(), name: "QUERY");
    // dev.log(maryResponse.toString(), name: "RESPONSE");
    dev.log(sessionId.toString(), name: "SESSION-ID");
    dev.log(patientId.toString(), name: "PATIENT-ID");
    // dev.log(patients.length.toString(), name: "patients");
    // dev.log(AppConstants().meldRxAccessTokenExpiry.toString());
  }

  Future<String?> showPatientSelectionDialog(List<Patient> patients) async {
    return await showModalBottomSheet(
      isDismissible: false,
      // isScrollControlled: true,
      context: navKey.currentContext!,
      builder: (BuildContext context) {
        String patientID = '';
        return SizedBox(
          height: 400.w,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    // SizedBox(height: 30),
                    Text(
                      maryResponse ?? "",
                      style: MaryStyle().white16w500.copyWith(
                        color: MaryStyle().black,
                      ),
                    ),
                    SizedBox(height: 10.w),
                    SizedBox(
                      height: 200,
                      child: SingleChildScrollView(
                        child: Column(
                          children: List.generate(patients.length, (index) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: MaryStyle().black),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value:
                                        patients[index]
                                            .id, // Pass the index as the value
                                    groupValue: patientID,
                                    onChanged: (String? value) {
                                      setState(() {
                                        patientID = value ?? "";
                                      });
                                    },
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(patients[index].name),
                                      Text(
                                        'DOB: ${DateFormat('dd MMM, yyyy').format(patients[index].dob)}',
                                        style: MaryStyle().white12w400.copyWith(
                                          color: MaryStyle().black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    Divider(),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, patientID);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MaryStyle().palatinateBlue,
                        minimumSize: Size.fromHeight(50.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                      ),
                      child: Text('Submit', style: MaryStyle().white16w500),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  initSpeechToText() async {
    if (await _speechToText.initialize()) {
      dev.log("speech to text initialized", name: "initSpeechToText()");
      isAvailable = true;
      notifyListeners();
    }
  }

  tokenExpired() {
    ScaffoldMessenger.of(navKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(
          'TOKEN Expired, Sign in to MeldRx',
          style: MaryStyle().white16w500,
        ),
        backgroundColor: MaryStyle().vividCrulian,
      ),
    );
  }

  fetchConversationBySessionId(String id) async {
    dev.log(id, name: "fetchConversationBySessionId()");
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      var conversationResponse = await ApiService().getRequest(
        "${AppConstants().conversation}/$id",
      );

      Conversation c = Conversation(
        conversationResponse
            .map((e) => ConversationPiece.fromJSON(e))
            .toList()
            .cast<ConversationPiece>(),
      );
      conversation = c;
      isLoading = false;
      error = null;
      notifyListeners();
    } catch (e) {
      dev.log(e.toString(), name: "fetchConversationBySessionId Error");
      isLoading = false;
      error = e.toString();
    }
  }

  destroySession() {
    isRecording = false;
    isLoading = false;
    waitingForResponse = false;
    sessionId = null;
    patientId = null;
    error = null;
    // patients = [];
    conversation = Conversation.fromJSON([]);
    maryResponse = null;
    maryQuery = null;
    notifyListeners();
  }

  initSession({
    required String sessionId,
    required String patientId,
    Conversation? conversation,
    String? query,
    String? response,
    bool callNotifyListeners = true,
  }) {
    maryQuery = query;
    maryResponse = response;
    this.sessionId = sessionId;
    this.patientId = patientId;
    error = null;
    this.conversation = conversation ?? Conversation([]);
    isLoading = false;
    waitingForResponse = false;
    isRecording = false;
    if (callNotifyListeners) {
      notifyListeners();
    }
  }
}

final ChangeNotifierProvider<ChatNotifier> chatProvider =
    ChangeNotifierProvider<ChatNotifier>((ref) => ChatNotifier());
