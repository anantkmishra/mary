import "package:flutter/material.dart";
import "package:mary/constants/image_assets.dart";
import "package:mary/routing/routes.dart";
import "package:mary/style/style.dart";
import "package:mary/utils/widgets.dart";
import "dart:developer" as dev;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dev.log(maryAppRouter.state.fullPath ?? "", name: "PATH ");
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  roundIconButton(onTap: () {}, icon: MaryAssets.menu3SVG),
                  roundIconButton(onTap: () {}, icon: MaryAssets.settingSVG),
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
            ],
          ),
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
              navigateTo(MaryAppRoutes.chat);
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
