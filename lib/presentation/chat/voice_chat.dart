import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:mary/constants/image_assets.dart';
import 'package:mary/providers/chat_provider.dart';
import 'package:mary/routing/router.dart';
import 'package:mary/routing/routes.dart';
import 'package:mary/style/style.dart';
import 'package:mary/utils/widgets.dart';
import 'dart:developer' as dev;

class MaryVoiceChat extends ConsumerStatefulWidget {
  const MaryVoiceChat({super.key, this.newChat = true});
  final bool newChat;

  @override
  ConsumerState<MaryVoiceChat> createState() => _MaryVoiceChatState();
}

class _MaryVoiceChatState extends ConsumerState<MaryVoiceChat> {
  @override
  void initState() {
    super.initState();
    dev.log(maryAppRouter.state.fullPath ?? "", name: "PATH ");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = ref.read(chatProvider);
      provider.initSpeechToText();
      provider.initTts();
      provider.clearQR();
      if (widget.newChat) {
        provider.destroySession();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final provider = ref.watch(chatProvider);
    return PopScope(
      onPopInvokedWithResult: (k, t) {
        provider.maryStopSpeaking();
      },
      child: Scaffold(
        backgroundColor: MaryStyle().darkBg,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: (width - 200) / 2 - 100,
                top: height / 4 - 50,
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [MaryStyle().persianBlue, Color(0x00000000)],
                      radius: 0.8,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: (width - 200) / 2 + 100,
                top: height / 4 + 50,
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [MaryStyle().vividCrulian, Color(0x00000000)],
                      radius: 0.6,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: (width - 200.w) / 2,
                top: height / 4,
                child:
                    provider.isAvailable
                        ? Lottie.asset(
                          MaryAssets.maryJSON,
                          repeat: true,
                          height: 200.w,
                          width: 200.w,
                        )
                        : svgAssetImageWidget(
                          MaryAssets.maryVoiceLogoSVG,
                          height: 200.w,
                          width: 200.w,
                        ),
              ),
              SizedBox(
                height: height,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          roundIconButton(
                            onTap: () {
                              provider.maryStopSpeaking();
                              navigateBack();
                            },
                            icon: MaryAssets.leftArrowSVG,
                          ),
                          Column(
                            children: [
                              Text(
                                "Speaking to Mary",
                                style: MaryStyle().white16w500,
                              ),
                              Text(
                                "Go ahead, I’m Listening",
                                style: MaryStyle().white14w400.copyWith(
                                  color: MaryStyle().cadetGray,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 48.w),
                        ],
                      ),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.only(top: 150.w, bottom: 150.w),
                          shrinkWrap: true,
                          children: [
                            Text(
                              provider.maryQuery ?? "",
                              style: MaryStyle().white20w500,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20.w),
                            Text(
                              provider.maryResponse ?? "",
                              style: MaryStyle().white16w500.copyWith(
                                color: MaryStyle().white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          height: 150.w,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MaryStyle().darkBg, MaryStyle().darkBg.withAlpha(0)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              roundIconButton(
                onTap: () {
                  provider.maryStopSpeaking();
                  navigateTo(
                    MaryAppRoutes.chat,
                    queryParams: {"newchat": "false"},
                  );
                },
                icon: MaryAssets.chatbubbleSVG,
              ),

              provider.isAvailable
                  ? AvatarGlow(
                    glowCount: 3,
                    duration: Duration(seconds: 1),
                    animate: provider.isRecording,
                    child: InkWell(
                      onTapUp: (_) {
                        provider.stopRecording();
                        // ref.read(maryChatProvider.notifier).stopRecording();
                      },
                      onTapDown: (_) {
                        provider.clearQR();
                        provider.maryStopSpeaking();
                        provider.startRecording();
                        // ref.read(maryChatProvider.notifier).startRecording();
                      },
                      customBorder: CircleBorder(),

                      child: ClipOval(
                        child: Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                MaryStyle().palatinateBlue,
                                MaryStyle().darkBg,
                              ],
                              radius: 0.7,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: svgAssetImageWidget(
                            MaryAssets.microphoneSVG,
                            height: 40,
                            width: 40,
                          ),
                        ),
                      ),
                    ),
                  )
                  : CircularProgressIndicator(),

              roundIconButton(
                onTap: () {
                  navigateBack();
                },
                icon: MaryAssets.exitSVG,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
