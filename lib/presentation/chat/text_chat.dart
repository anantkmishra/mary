import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mary/constants/image_assets.dart';
import 'package:mary/models/conversation.dart';
import 'package:mary/providers/mary_chat_provider.dart';
import 'dart:developer' as dev;

import 'package:mary/routing/routes.dart';
import 'package:mary/style/style.dart';
import 'package:mary/utils/widgets.dart';

class MaryTextChat extends ConsumerStatefulWidget {
  const MaryTextChat({super.key});

  @override
  ConsumerState<MaryTextChat> createState() => _MaryTextChatState();
}

class _MaryTextChatState extends ConsumerState<MaryTextChat> {
  final TextEditingController query = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dev.log(maryAppRouter.state.fullPath ?? "", name: "PATH ");
  }

  @override
  void dispose() {
    super.dispose();
    query.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(maryChatProvider);
    return Scaffold(
      backgroundColor: MaryStyle().darkBg,
      body: Container(
        padding: EdgeInsets.only(top: 60, left: 15, right: 15, bottom: 20),
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
                Text("New Chat", style: MaryStyle().white16w500),
                roundIconButton(
                  onTap: () {
                    // _showPopupMenu(context);
                    ref.read(maryChatProvider.notifier).destroySession();
                  },
                  icon: MaryAssets.menu4SVG,
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: provider.conversation.data.length,
                padding: EdgeInsets.only(bottom: 100),
                itemBuilder: (context, index) {
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
                        height: 25,
                        width: 25,
                      ),
                    ),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child:
                        provider.waitingForResponse
                            ? CircularProgressIndicator(
                              color: MaryStyle().cadetGray,
                            )
                            : InkWell(
                              onTap: () {
                                ref
                                    .read(maryChatProvider.notifier)
                                    .sendQuery(query.text);
                                query.text = "";
                              },
                              child: svgAssetImageWidget(
                                MaryAssets.sendSVG,
                                color: MaryStyle().cadetGray,
                                height: 25,
                                width: 25,
                              ),
                            ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            ClipOval(
              child: InkWell(
                onTap: () {
                  ref.read(maryChatProvider.notifier).f();
                },
                customBorder: CircleBorder(),
                child: Container(
                  height: 64,
                  width: 64,
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
                    height: 24,
                    width: 24,
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

  chatBubble(ConversationPiece statement) {
    final br = Radius.circular(20);
    return Align(
      alignment:
          statement.role == ConversationRole.user
              ? Alignment.centerRight
              : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        // width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: MaryStyle().cadetGray),
          borderRadius: BorderRadius.only(
            topLeft: br,
            topRight: br,
            bottomLeft:
                statement.role == ConversationRole.assistant ? Radius.zero : br,
            bottomRight:
                statement.role == ConversationRole.user ? Radius.zero : br,
          ),
        ),
        child: Text(
          statement.content,
          style: MaryStyle().white14w400,
          textAlign:
              statement.role == ConversationRole.user
                  ? TextAlign.end
                  : TextAlign.start,
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
