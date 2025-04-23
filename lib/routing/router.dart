import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mary/main.dart';
import 'package:mary/models/chat_data.dart';

import 'package:mary/presentation/chat/text_chat.dart';
import 'package:mary/presentation/chat/voice_chat.dart';
import 'package:mary/presentation/home/home.dart';
import 'package:mary/routing/routes.dart';
import 'dart:developer' as dev;

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

final GoRouter maryAppRouter = GoRouter(
  navigatorKey: navKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: MaryAppRoutes.root.path,
      name: MaryAppRoutes.root.name,
      builder: (BuildContext context, GoRouterState state) {
        return Mary();
      },
    ),
    GoRoute(
      path: MaryAppRoutes.home.path,
      name: MaryAppRoutes.home.name,
      builder: (BuildContext context, GoRouterState state) {
        return Home();
      },
      routes: [
        GoRoute(
          path: MaryAppRoutes.voiceChat.path,
          name: MaryAppRoutes.voiceChat.name,
          builder: (BuildContext context, GoRouterState state) {
            if (state.uri.queryParameters.isNotEmpty) {
              if (state.uri.queryParameters.containsKey('newchat')) {
                return MaryVoiceChat(
                  newChat: state.uri.queryParameters["newchat"] == "true",
                );
              }
            }
            return MaryVoiceChat();
          },
        ),
        GoRoute(
          path: MaryAppRoutes.chat.path,
          name: MaryAppRoutes.chat.name,
          builder: (BuildContext context, GoRouterState state) {
            ChatData? cd;
            try {
              if (state.extra != null && state.extra is ChatData?) {
                cd = state.extra as ChatData;
              } else {
                cd = null;
              }
            } catch (e) {
              cd = null;
              dev.log("$e", name: "Router Error");
            }
            return MaryTextChat(
              chatData: cd,
              newChat:
                  state.uri.queryParameters.containsKey("newchat")
                      ? state.uri.queryParameters["newchat"] == "true"
                      : true,
            );
          },
        ),
      ],
    ),
  ],
);

void navigateTo(
  MaryAppRoutes route, {
  Map<String, String>? queryParams,
  Map<String, String>? pathParams,
  Object? extra,
}) {
  maryAppRouter.goNamed(
    route.name,
    queryParameters: queryParams ?? {},
    pathParameters: pathParams ?? {},
    extra: extra,
  );
}

void navigateBack() {
  maryAppRouter.pop();
}
