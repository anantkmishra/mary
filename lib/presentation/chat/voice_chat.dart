import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
// import 'package:mary/constants/constants.dart';
import 'package:mary/constants/image_assets.dart';
import 'package:mary/providers/mary_chat_provider.dart';
import 'package:mary/routing/router.dart';
import 'package:mary/routing/routes.dart';
import 'package:mary/style/style.dart';
import 'package:mary/utils/widgets.dart';
import 'dart:developer' as dev;

class MaryVoiceChat extends ConsumerStatefulWidget {
  const MaryVoiceChat({super.key});

  @override
  ConsumerState<MaryVoiceChat> createState() => _MaryVoiceChatState();
}

class _MaryVoiceChatState extends ConsumerState<MaryVoiceChat> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dev.log(maryAppRouter.state.fullPath ?? "", name: "PATH ");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(maryChatProvider.notifier).initSpeechToText();
      ref.read(maryChatProvider.notifier).initTts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final provider = ref.watch(maryChatProvider);
    return Scaffold(
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
              left: (width - 200) / 2,
              top: height / 4,
              child: svgAssetImageWidget(
                MaryAssets.maryVoiceLogoSVG,
                height: 200,
                width: 200,
              ),
            ),
            // Positioned(
            //   left: (width - 200) / 2,
            //   top: height / 4,
            //   child: Lottie.asset(
            //     MaryAssets.maryJSON,
            //     repeat: true,
            //     height: 200.w,
            //     width: 200.w,
            //   ),

            //   // svgAssetImageWidget(
            //   //   MaryAssets.maryVoiceLogoSVG,
            //   //   height: 200,
            //   //   width: 200,
            //   // ),
            // ),
            SizedBox(
              height: height,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        roundIconButton(
                          onTap: navigateBack,
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

                        roundIconButton(
                          onTap: () {
                            ref
                                .read(maryChatProvider.notifier)
                                .destroySession();
                          },
                          icon: MaryAssets.menu4SVG,
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // SizedBox(height: 100),
                          Text(
                            provider.query ?? "",
                            style: MaryStyle().white20w500,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20.w),
                          Text(
                            provider.response ?? "",
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            roundIconButton(
              onTap: () {
                navigateTo(MaryAppRoutes.chat);
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
                      ref.read(maryChatProvider.notifier).stopRecording();
                    },
                    onTapDown: (_) {
                      ref.read(maryChatProvider.notifier).startRecording();
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

            roundIconButton(onTap: () {}, icon: MaryAssets.exitSVG),
          ],
        ),
      ),
    );
  }
}
