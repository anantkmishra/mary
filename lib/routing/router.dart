import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mary/main.dart';
import 'package:mary/presentation/auth/login.dart';
import 'package:mary/presentation/auth/meld_rx_login.dart';
import 'package:mary/presentation/chat/previous_chat.dart';
import 'package:mary/presentation/chat/text_chat.dart';
import 'package:mary/presentation/chat/voice_chat.dart';
import 'package:mary/presentation/home/home.dart';
import 'package:mary/routing/routes.dart';

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
      routes: [
        GoRoute(
          path: MaryAppRoutes.login.path,
          name: MaryAppRoutes.login.name,
          builder: (BuildContext context, GoRouterState state) {
            return Login();
          },
        ),
        GoRoute(
          path: MaryAppRoutes.meldRxLogin.path,
          name: MaryAppRoutes.meldRxLogin.name,
          builder: (BuildContext context, GoRouterState state) {
            return MeldRxLogin();
          },
        ),
      ],
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
            return MaryVoiceChat();
          },
        ),
        GoRoute(
          path: MaryAppRoutes.chat.path,
          name: MaryAppRoutes.chat.name,
          builder: (BuildContext context, GoRouterState state) {
            return MaryTextChat();
          },
        ),
        GoRoute(
          path: MaryAppRoutes.previousChat.path,
          name: MaryAppRoutes.previousChat.name,
          builder: (BuildContext context, GoRouterState state) {
            
            return PreviousChat(
              conversatioID: state.pathParameters["conversation_id"] ?? "",
              title: state.pathParameters["title"] ?? "",
            );
          },
        ),
      ],
    ),
  ],
);

navigateTo(
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

navigateBack() {
  maryAppRouter.pop();
}