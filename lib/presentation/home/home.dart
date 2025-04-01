import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:mary/constants/image_assets.dart";
import "package:mary/models/chat_data.dart";
import "package:mary/providers/recent_chat_provider.dart";
import "package:mary/routing/router.dart";
import "package:mary/routing/routes.dart";
import "package:mary/style/style.dart";
import "package:mary/utils/methods.dart";
import "package:mary/utils/widgets.dart";
import "dart:developer" as dev;

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      ref.read(recentChatProvider.notifier).fetchConversations();
    });
    dev.log(maryAppRouter.state.fullPath ?? "", name: "PATH ");
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final recentChatController = ref.watch(recentChatProvider);
    return Scaffold(
      backgroundColor: MaryStyle().darkBg,
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              MaryStyle().persianBlue,
              MaryStyle().persianBlue.withAlpha(0),
            ],
            stops: [0, 1],
            center: Alignment.topCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                roundIconButton(onTap: () {}, icon: MaryAssets.menu3SVG),
                roundIconButton(
                  onTap: () {
                    // AppConstants().show();
                  },
                  icon: MaryAssets.settingSVG,
                ),
              ],
            ),
            SizedBox(height: 30),
            Text("Hi John", style: MaryStyle().grey16w500),
            Text(
              "Let’s see what can I do for you?",
              style: MaryStyle().white20w500,
            ),
            SizedBox(height: 30),
            SizedBox(
              height: height * 0.22,
              child: Row(
                children: [
                  Expanded(child: voiceRecordingCard()),
                  Expanded(child: newChatCards()),
                ],
              ),
            ),
            SizedBox(height: 30.w),
            Text("Recent Chats", style: MaryStyle().white18w700),
            if (recentChatController.error != null)
              Text(
                recentChatController.error ?? "",
                style: MaryStyle().grey16w500,
              ),
            if (recentChatController.isLoading)
              Center(
                child: CircularProgressIndicator(color: MaryStyle().white),
              ),
            if (recentChatController.recentChats.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: recentChatController.recentChats.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // navigateTo()

                        navigateTo(
                          MaryAppRoutes.previousChat,
                          pathParams: {
                            "title":
                                recentChatController.recentChats[index].title,
                            "conversation_id":
                                recentChatController
                                    .recentChats[index]
                                    .conversationId,
                          },
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 16.w,
                          horizontal: 24.w,
                        ),
                        margin: EdgeInsets.only(bottom: 16.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF353535)),
                          color: Color(0xFF23272E),
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                recentChatController.recentChats[index].title,
                                style: MaryStyle().white16w500,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              xTimeAgo(
                                recentChatController
                                    .recentChats[index]
                                    .createdAt,
                              ),
                              style: MaryStyle().white12w400,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // TODO:
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: ,
            //     itemBuilder: {

            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget voiceRecordingCard() {
    return Container(
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: AssetImage(MaryAssets.voiceChatCardPNG),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Color(0x3CFFFFFF),
              child: svgAssetImageWidget(MaryAssets.microphoneSVG),
            ),
          ),

          Text(
            "Let’s Analyze patient data using voice recording",
            style: MaryStyle().white14w400,
          ),

          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: MaryStyle().white,
              shape: StadiumBorder(),
              minimumSize: Size.fromHeight(30),
            ),
            child: Text("Start Recording", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget newChatCards() {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              navigateTo(MaryAppRoutes.voiceChat);
            },
            child: Container(
              decoration: BoxDecoration(
                color: MaryStyle().cardBG,
                border: Border.all(width: 1, color: MaryStyle().jetBlack),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Color(0x3CFFFFFF),
                    child: svgAssetImageWidget(
                      MaryAssets.chatbubbleSVG,
                      height: 16,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text("Start New Chat", style: MaryStyle().white12w400),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: GestureDetector(
            onTap: () {
              navigateTo(MaryAppRoutes.voiceChat);
              // navigateTo(MaryAppRoutes.chat);
            },
            child: Container(
              decoration: BoxDecoration(
                color: MaryStyle().cardBG,
                border: Border.all(width: 1, color: MaryStyle().jetBlack),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Color(0x3CFFFFFF),
                    child: svgAssetImageWidget(
                      MaryAssets.stethoscopeSVG,
                      height: 16,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text("Search Patient Data", style: MaryStyle().white12w400),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
