import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:mary/constants/image_assets.dart';
import 'package:mary/models/chat_data.dart';
import 'package:mary/providers/chat_provider.dart';
import 'package:mary/providers/mary_chat_provider.dart';
import 'package:mary/routing/router.dart';
import 'dart:developer' as dev;

import 'package:mary/routing/routes.dart';
import 'package:mary/style/style.dart';
import 'package:mary/utils/widgets.dart';

class MaryTextChat extends ConsumerStatefulWidget {
  const MaryTextChat({super.key, this.chatData});
  final ChatData? chatData;

  @override
  ConsumerState<MaryTextChat> createState() => _MaryTextChatState();
}

class _MaryTextChatState extends ConsumerState<MaryTextChat> {
  final TextEditingController query = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dev.log(maryAppRouter.state.fullPath ?? "", name: "PATH ");
    if (widget.chatData != null) {
      WidgetsBinding.instance.addPostFrameCallback((t) {
        final provider = ref.read(chatProvider);
        // provider.destroySession();
        provider.initSession(
          patientId: widget.chatData!.patientId,
          sessionId: widget.chatData!.conversationId,
          callNotifyListeners: false,
        );
        provider.fetchConversationBySessionId(
          widget.chatData?.conversationId ?? "",
        );
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    query.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final provider = ref.watch(maryChatProvider);
    final provider = ref.watch(chatProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: MaryStyle().darkBg,
      body: Container(
        padding: EdgeInsets.only(
          top: 60.w,
          left: 15.w,
          right: 15.w,
          bottom: 20.w,
        ),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              MaryStyle().persianBlue,
              MaryStyle().persianBlue.withAlpha(0),
            ],
            stops: [0, 0.8],
            center: Alignment.topCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                roundIconButton(
                  onTap: () {
                    navigateBack();
                  },
                  icon: MaryAssets.leftArrowSVG,
                ),
                SizedBox(width: 10.w),
                Flexible(
                  child: Text(
                    widget.chatData?.title ?? "New Chat",
                    style: MaryStyle().white16w500,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 10.w),
                roundIconButton(
                  onTap: () {
                    // _showPopupMenu(context);
                    // ref.read(maryChatProvider.notifier).destroySession();
                    // provider.destroySession();
                    provider.f();
                  },
                  icon: MaryAssets.menu4SVG,
                ),
              ],
            ),
            if (provider.error != null)
              Expanded(
                child: Center(
                  child: Text(
                    provider.error!,
                    style: MaryStyle().white16w500,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (provider.isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: MaryStyle().white),
                ),
              ),
            if (provider.conversation.data.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.conversation.data.length,
                  padding: EdgeInsets.only(bottom: 100.w),
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    if (index == provider.conversation.data.length - 1 &&
                        provider.waitingForResponse) {
                      return Column(
                        children: [
                          chatBubble(provider.conversation.data[index]),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Lottie.asset(
                              MaryAssets.typingJSON,
                              height: 50,
                            ),
                          ),
                        ],
                      );
                    }
                    return chatBubble(provider.conversation.data[index]);

                    // return Text("Chat $index", style: MaryStyle().white16w500);
                  },
                ),
              ),
            // SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: query,
                style: MaryStyle().white16w500,
                cursorColor: MaryStyle().cadetGray,
                maxLines: null,
                onTapOutside: (pde) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: InputDecoration(
                  fillColor: MaryStyle().gunmetal,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(color: MaryStyle().lightSilver),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(color: MaryStyle().lightSilver),
                  ),
                  hintText: "Send a Messsage",
                  hintStyle: MaryStyle().white16w500,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        dev.log("PREFIX ICON TAPPED");
                      },
                      child: svgAssetImageWidget(
                        MaryAssets.add2SVG,
                        color: MaryStyle().cadetGray,
                        height: 25.w,
                        width: 25.w,
                      ),
                    ),
                  ),

                  suffixIcon: Padding(
                    padding: EdgeInsets.all(10.0.w),
                    child:
                    // provider.waitingForResponse
                    //     ? CircularProgressIndicator(
                    //       color: MaryStyle().cadetGray,
                    //     )
                    // :
                    InkWell(
                      onTap: () {
                        if (query.text.isNotEmpty) {
                          // final pv = ref.read(maryChatProvider.notifier);
                          provider.addQuery(query.text);
                          provider.sendQuery(query.text);
                          query.text = "";
                          FocusManager.instance.primaryFocus?.unfocus();
                        }
                      },
                      child: svgAssetImageWidget(
                        MaryAssets.sendSVG,
                        color: MaryStyle().cadetGray,
                        height: 25.w,
                        width: 25.w,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            ClipOval(
              child: InkWell(
                onTap: () {
                  navigateTo(MaryAppRoutes.voiceChat);
                },
                customBorder: CircleBorder(),
                child: Container(
                  height: 64.w,
                  width: 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        MaryStyle().palatinateBlue,
                        MaryStyle().vividCrulian,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: svgAssetImageWidget(
                    MaryAssets.microphoneSVG,
                    height: 24.w,
                    width: 24.w,
                    color: MaryStyle().white,
                  ),
                ),
              ),
            ),
            // roundIconButton(onTap: () {}, icon: ),
          ],
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context) async {
    // Define the position to show the menu
    RenderBox button = context.findRenderObject() as RenderBox;
    var buttonPosition = button.localToGlobal(
      Offset.zero,
    ); // Get position of the button
    var buttonSize = button.size;

    // Show the menu
    await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx, // X position (left of button)
        buttonPosition.dy + buttonSize.height, // Y position (just below button)
        buttonPosition.dx +
            buttonSize.width, // Right position (right of button)
        buttonPosition.dy, // Top position (just above button)
      ),
      items: [
        PopupMenuItem<String>(value: 'Option 1', child: Text('Option 1')),
        PopupMenuItem<String>(value: 'Option 2', child: Text('Option 2')),
        PopupMenuItem<String>(value: 'Option 3', child: Text('Option 3')),
      ],
    ).then((value) {
      if (value != null) {
        // Do something with the selected value
        print('Selected: $value');
      }
    });
  }
}
