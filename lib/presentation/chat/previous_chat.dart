import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mary/providers/previous_chat_provider.dart';
import 'package:mary/style/style.dart';
import 'package:mary/utils/widgets.dart';

class PreviousChat extends ConsumerStatefulWidget {
  const PreviousChat({
    super.key,
    required this.conversatioID,
    required this.title,
  });
  final String conversatioID;
  final String title;

  @override
  ConsumerState<PreviousChat> createState() => _PreviousChatState();
}

class _PreviousChatState extends ConsumerState<PreviousChat> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      final provider = ref.read(previousChatProvider.notifier);
      provider.clearChat();
      provider.fetchConversation(widget.conversatioID);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(previousChatProvider);
    WidgetsBinding.instance.addPostFrameCallback((t) {
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //     roundIconButton(
                //       onTap: () {
                //         navigateBack();
                //       },
                //       icon: MaryAssets.leftArrowSVG,
                //     ),
                Flexible(
                  child: Text(
                    widget.title,
                    style: MaryStyle().white18w700,
                    textAlign: TextAlign.center,
                  ),
                ),
                // roundIconButton(
                //   onTap: () {
                //     // _showPopupMenu(context);
                //     // ref.read(maryChatProvider.notifier).destroySession();
                //   },
                //   icon: MaryAssets.menu4SVG,
                // ),
              ],
            ),
            // Text(
            //   "${provider.error} ${provider.isLoading} ${provider.conversation.data.length}",
            //   style: MaryStyle().white16w500,
            // ),
            if (provider.error != null)
              Expanded(
                child: Center(
                  child: Text(
                    provider.error ?? "",
                    style: MaryStyle().white14w400,
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
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    return chatBubble(provider.conversation.data[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
