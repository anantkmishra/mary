import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mary/constants/constants.dart';
import 'package:mary/models/chat_data.dart';
import 'package:mary/models/conversation.dart';
import 'package:mary/models/patient.dart';
import 'package:mary/routing/router.dart';
import 'package:mary/routing/routes.dart';
import 'package:mary/services/api_service_provider.dart';
import 'package:mary/style/style.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:developer' as dev;
import 'package:flutter_tts/flutter_tts.dart';

@immutable
class MaryChatData {
  final bool isRecording;
  final bool isAvailable;
  final bool waitingForResponse;
  final String? query;
  final String? patientId;
  final String? sessionId;
  final String? response;
  final Conversation conversation;
  final List<Patient> patients;

  const MaryChatData({
    this.isRecording = false,
    this.isAvailable = true,
    this.waitingForResponse = false,
    required this.query,
    required this.patientId,
    required this.sessionId,
    required this.response,
    required this.conversation,
    required this.patients,
  });

  MaryChatData copyWith({
    bool? isRecording,
    bool? isAvailable,
    bool? waitingForResponse,
    String? query,
    String? patientId,
    String? sessionId,
    String? response,
    Conversation? conversation,
    List<Patient>? patients,
  }) {
    return MaryChatData(
      isAvailable: isAvailable ?? this.isAvailable,
      isRecording: isRecording ?? this.isRecording,
      waitingForResponse: waitingForResponse ?? this.waitingForResponse,
      query: query ?? this.query,
      patientId: patientId ?? this.patientId,
      sessionId: sessionId ?? this.sessionId,
      response: response ?? this.response,
      conversation: conversation ?? this.conversation,
      patients: patients ?? this.patients,
    );
  }

  factory MaryChatData.fromJSON(Map<String, dynamic> json) {
    return MaryChatData(
      query: json["query"],
      patientId: json["patient_id"],
      sessionId: json["session_id"],
      response: json["response"],
      conversation: Conversation.fromJSON(
        json.containsKey("conversation") ? json["conversation"] : [],
      ),
      patients:
          json.containsKey("patients")
              ? json["patients"]
                  .map((e) => Patient.fromJSON(e))
                  .toList()
                  .cast<Patient>()
              : <Patient>[],
    );
  }
}

enum TtsState { playing, stopped, paused, continued }

class MaryChatNotifier extends StateNotifier<MaryChatData> {
  MaryChatNotifier() : super(MaryChatData.fromJSON({}));

  // final Ref ref;
  late FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;

  initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
  }

  marySpeak(String textToSpeak) {
    flutterTts.speak(textToSpeak);
  }

  startRecording() {
    state = state.copyWith(isRecording: true);
    if (state.isAvailable) {
      _speechToText.listen(
        onResult: (val) {
          dev.log(val.recognizedWords, name: "recognized Words >>> ");
          state = state.copyWith(query: val.recognizedWords);
        },
      );
    }
  }

  stopRecording() {
    state = state.copyWith(isRecording: false);
    _speechToText.stop();
    if (state.query?.isNotEmpty ?? false) {
      sendQuery(state.query ?? "", speak: true);
    }
  }

  sendQuery(String query, {bool speak = false}) async {
    //api call for query
    Map<String, String> queryParamsBody = <String, String>{
      "access_token": AppConstants().meldRxAccessToken ?? "",
      "query": query,
    };

    if (state.sessionId != null) {
      queryParamsBody["session_id"] = state.sessionId ?? "";
    }

    if (state.patientId != null) {
      queryParamsBody["patient_id"] = state.patientId ?? "";
    }

    String queryParams = Uri(queryParameters: queryParamsBody).query;

    state = state.copyWith(waitingForResponse: true);

    Map<String, dynamic> response = await ApiService().postRequest(
      'query?$queryParams',
    );

    handleResponse(response);

    if (speak) {
      marySpeak(state.response ?? "");
    }
  }

  addQuery(String q) {
    ConversationPiece cp = ConversationPiece(
      role: ConversationRole.user,
      content: q,
    );

    state = state.copyWith(
      conversation: Conversation([...state.conversation.data, cp]),
    );
  }

  handleResponse(Map<String, dynamic> res) async {
    dev.log('handleResponse()', name: "function()");

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

    state = state.copyWith(
      waitingForResponse: false,
      query: newData.query ?? state.query,
      response: newData.response ?? state.response,
      patientId: newData.patientId ?? state.patientId,
      sessionId: newData.sessionId ?? state.sessionId,
      conversation: newData.conversation,
      patients: newData.patients.isEmpty ? state.patients : newData.patients,
    );
    if (res.containsKey("requires_selection")) {
      if (res.containsKey("patients")) {
        showPatientSelectionDialog().then((patientID) {
          dev.log("$patientID", name: "showPatientSelectionDialog");
          if (patientID != null) {
            state = state.copyWith(patientId: patientID);
          }
        });
      }

      // showPatientSelectionDialog().then((selectedPatient) {
      //   res["patient_id"] = selectedPatient;
      //   state = MaryChatData.fromJSON(res);
      // });
    }
    //queryResponse
  }

  f() {
    dev.log(
      state.conversation.data.length.toString(),
      name: "conversation length",
    );
    dev.log(state.response.toString(), name: "RESPONSE");
    dev.log(state.sessionId.toString(), name: "SESSION-ID");
    dev.log(state.patientId.toString(), name: "PATIENT-ID");
    dev.log(state.patients.length.toString(), name: "patients");
    dev.log(AppConstants().meldRxAccessTokenExpiry.toString());
  }

  Future<String?> showPatientSelectionDialog() async {
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
                      state.response ?? "",
                      style: MaryStyle().white16w500.copyWith(
                        color: MaryStyle().black,
                      ),
                    ),
                    SizedBox(height: 10.w),
                    // Text(state.patients.length.toString()),

                    /*
                    SizedBox(
                      height: 100.w,
                      child: ListView.separated(
                        shrinkWrap: true,
                        separatorBuilder: (_, __) {
                          return Divider();
                        },
                        itemCount: state.patients.length,
                        itemBuilder: (context, index) {
                          ListTile(
                            title: Text(state.patients[index].name),
                            subtitle: Text(
                              'DOB: ${DateFormat('dd MMM, yyyy').format(state.patients[index].dob)}',
                              style: MaryStyle().white12w400.copyWith(
                                color: MaryStyle().black,
                              ),
                            ),
                            leading: Radio<String>(
                              value:
                                  state
                                      .patients[index]
                                      .id, // Pass the index as the value
                              groupValue: patientID,
                              onChanged: (String? value) {
                                setState(() {
                                  patientID = value ?? "";
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),*/
                    SizedBox(
                      height: 200,
                      child: SingleChildScrollView(
                        child: Column(
                          children: List.generate(state.patients.length, (
                            index,
                          ) {
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
                                        state
                                            .patients[index]
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
                                      Text(state.patients[index].name),
                                      Text(
                                        'DOB: ${DateFormat('dd MMM, yyyy').format(state.patients[index].dob)}',
                                        style: MaryStyle().white12w400.copyWith(
                                          color: MaryStyle().black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                            // return ListTile(
                            //   title: Text(
                            //     state.patients[index].name,
                            //     style: MaryStyle().white12w400.copyWith(
                            //       color: MaryStyle().black,
                            //     ),
                            //   ),
                            //   subtitle: Text(
                            //     'DOB: ${DateFormat('dd MMM, yyyy').format(state.patients[index].dob)}',
                            //   ),
                            //   leading: Radio<String>(
                            //     value:
                            //         state
                            //             .patients[index]
                            //             .id, // Pass the index as the value
                            //     groupValue: patientID,
                            //     onChanged: (String? value) {
                            //       setState(() {
                            //         patientID = value ?? "";
                            //       });
                            //     },
                            //   ),
                            // );
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

  final SpeechToText _speechToText = SpeechToText();

  initSpeechToText() async {
    if (await _speechToText.initialize()) {
      dev.log("speech to text initialized", name: "initSpeechToText()");
      state = state.copyWith(isAvailable: true);
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

  destroySession() {
    state = state.copyWith(
      sessionId: null,
      patientId: null,
      patients: [],
      conversation: Conversation.fromJSON([]),
      response: null,
      query: null,
    );
  }
}

final StateNotifierProvider<MaryChatNotifier, MaryChatData> maryChatProvider =
    StateNotifierProvider<MaryChatNotifier, MaryChatData>(
      (ref) => MaryChatNotifier(),
    );
