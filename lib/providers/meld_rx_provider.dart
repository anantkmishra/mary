import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mary/constants/constants.dart';
import 'package:mary/routing/routes.dart';
import 'package:mary/services/api_service_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer' as dev;
import "dart:math";

import "package:crypto/crypto.dart";
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS/macOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

@immutable
class MeldRxData {
  final bool isControllerInitialized;
  final WebViewController? controller;
  final String? error;

  const MeldRxData({
    required this.isControllerInitialized,
    required this.controller,
    required this.error,
  });

  MeldRxData copyWith({
    bool? isControllerInitialized,
    WebViewController? controller,
    String? error,
    String? codeVerifier,
  }) {
    return MeldRxData(
      isControllerInitialized:
          isControllerInitialized ?? this.isControllerInitialized,
      controller: controller ?? this.controller,
      error: error ?? this.error,
    );
  }
}

class MeldRxNotifier extends StateNotifier<MeldRxData> {
  MeldRxNotifier()
    : super(
        MeldRxData(
          isControllerInitialized: false,
          controller: null,
          error: null,
        ),
      );

  init() {
    try {
      initAuthURL();
      dev.log(AppConstants().authURL ?? "null", name: "AUTHURL");

      // >> this function after initializing webviewcontroller, redirects to the authURL which after signing in and giving permissions, calls extractCode() and then fetchToken()
      initController();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      dev.log(e.toString(), name: "meldRxProvider Init Error");
    }
  }

  Future<void> initController() async {
    try {
      late final PlatformWebViewControllerCreationParams params;
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      final WebViewController controller =
          WebViewController.fromPlatformCreationParams(params)
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse(AppConstants().authURL ?? ""))
            ..setNavigationDelegate(
              NavigationDelegate(
                onProgress: (int progress) {
                  dev.log("$progress%", name: "onProgress()");
                },
                onPageStarted: (String url) {
                  dev.log(url, name: "onPageStarted()");
                },
                onPageFinished: (String url) {
                  dev.log(url, name: "onPageFinished()");
                },
                onWebResourceError: (WebResourceError error) {
                  dev.log(
                    "Page resource error: \ncode: ${error.errorCode}\n description: ${error.description} \nerrorType: ${error.errorType} \nisForMainFrame: ${error.isForMainFrame} ",
                    name: "onWebResourceError",
                  );
                },
                onNavigationRequest: (NavigationRequest request) {
                  dev.log(request.url, name: "onNavigationRequest");
                  // if (request.url.contains('unsafe-resource-url')) {
                  //   return NavigationDecision
                  //       .prevent; // Block or modify certain URLs if needed
                  // }

                  if (request.url.startsWith(
                    "https://mary.seecole.app/callback?code=",
                  )) {
                    fetchToken(request.url);
                    // return NavigationDecision.prevent;
                  }
                  return NavigationDecision.navigate;
                },
                onHttpError: (HttpResponseError error) {
                  dev.log(
                    "${error.request?.uri.authority} ${error.request?.uri.host} ${error.request?.uri.path} ${error.response?.statusCode}",
                    name: "onHttpError",
                  );
                },
                onUrlChange: (UrlChange change) {
                  dev.log(change.url ?? "", name: "onUrlChange()");
                },
                onHttpAuthRequest: (HttpAuthRequest request) {
                  dev.log(request.toString(), name: "onHttpAuthRequest()");
                },
              ),
            )
            ..addJavaScriptChannel(
              'Toaster',
              onMessageReceived: (JavaScriptMessage message) {
                dev.log(message.message, name: "onMessageReceived");
              },
            );
      controller.clearCache();
      state = state.copyWith(
        controller: controller,
        isControllerInitialized: true,
        error: null,
      );
    } catch (e) {
      dev.log(e.toString(), name: "WebViewController initialization Error");
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> fetchToken(String url) async {
    try {
      _extractCode(url);
      if (AppConstants().meldRxCode == null) {
        throw Exception("Could not extract code from url");
      }

      // if (!generateCodeVerifier()) {
      //   throw Exception("Could not generate Code Verifier");
      // }

      Map<String, dynamic> reqBody = {
        "client_id": AppConstants().clientID,
        "grant_type": "authorization_code", //"client_credentials"
        "code": AppConstants().meldRxCode,
        "redirect_uri": AppConstants().redirectUri,
        "scope": AppConstants().meldRxScopes,
        "code_verifier": AppConstants().meldRxCodeVerifier,
      };

      Map<String, dynamic> response = await ApiService().postRequest(
        AppConstants().meldRxGetToken,
        body: reqBody,
        isMeldRxRequest: true,
      );
      dev.log(response.toString(), name: "fetchToken RESPONSE");
      if (_initTokens(response)) {
        dev.log(
          AppConstants().meldRxAccessToken ?? "",
          name: "tokens INITIALIZED",
        );
        navigateTo(MaryAppRoutes.home);
      }
    } catch (e) {
      dev.log("$url $e", name: "fetchToken");
      state = state.copyWith(error: e.toString());
    }
  }

  bool _initTokens(Map<String, dynamic> data) {
    bool allInitialized = true;
    if (data.containsKey("id_token")) {
      AppConstants().setmeldRxIdToken(data["id_token"]);
    } else {
      allInitialized = false;
    }
    if (data.containsKey("access_token")) {
      AppConstants().setMeldRxAccessToken(data["access_token"]);
    } else {
      allInitialized = false;
    }
    if (data.containsKey("refresh_token")) {
      AppConstants().setmeldRxRefreshToken(data["refresh_token"]);
    } else {
      allInitialized = false;
    }
    if (data.containsKey("expires_in")) {
      AppConstants().setMeldRxAccessTokenExpiry(
        DateTime.now().add(Duration(seconds: data["expires_in"])),
      );
    } else {
      allInitialized = false;
    }
    return allInitialized;
  }

  String? _extractCode(String url) {
    try {
      url = url.split("?").cast<String>()[1];
      url = url
          .split("&")
          .cast<String>()
          .firstWhere((param) => param.startsWith("code="));
      url = url.split("=").cast<String>()[1];
      AppConstants().setmeldRxCode(url);
      dev.log(AppConstants().meldRxCode.toString(), name: "CODE");
      return url;
    } catch (e) {
      dev.log("$e > $url", name: "error while extracting code from url");
      return null;
    }
  }

  bool generateCodeVerifier() {
    try {
      final randomBytes = List<int>.generate(
        32,
        (i) => Random.secure().nextInt(256),
      );
      AppConstants().setmeldRxCodeVerifier(base64Url.encode(randomBytes));
      final Uint8List bytes = utf8.encode(AppConstants().meldRxCodeVerifier!);
      final Digest hash = sha256.convert(bytes);

      AppConstants().setmeldRxCodeVerifierSHA256Encoded(
        base64Url
            .encode(hash.bytes)
            .replaceAll('=', '')
            .replaceAll('+', '-')
            .replaceAll('/', '_'),
      );

      return true;
    } catch (e) {
      dev.log(e.toString(), name: "ERROR > generateCodeVerifier()");
      return false;
    }
  }

  // https://app.meldrx.com/connect/authorize
  // ?  client_id             = AppConstants().clientID
  // &  aud                   = AppConstants().meldRxWorkspaceURL
  // &  redirect              = AppConstants().redirectUri
  // &  scope                 = AppConstants().meldRxScopes
  // &  response_type         = code
  // &  code_challenge        = AppConstants().codeVerifier
  // &  code_challenge_method = S256;

  void initAuthURL() {
    try {
      generateCodeVerifier();
      String queryParams =
          Uri(
            queryParameters: {
              "client_id": AppConstants().clientID,
              "aud": AppConstants().meldRxWorkspaceURL,
              "redirect_uri": AppConstants().redirectUri,
              "scope": AppConstants().meldRxScopes,
              "response_type": "code",
              "code_challenge":
                  AppConstants().meldRxCodeVerifierSHA256Encoded ?? "",
              "code_challenge_method": "S256",
            },
          ).query;
      AppConstants().authURL =
          "https://app.meldrx.com/connect/authorize?$queryParams";

      return;
    } catch (e) {
      dev.log(e.toString(), name: "error > initAuthURL()");
      rethrow;
    }
  }
}

final StateNotifierProvider<MeldRxNotifier, MeldRxData> meldRxProvider =
    StateNotifierProvider<MeldRxNotifier, MeldRxData>(
      (ref) => MeldRxNotifier(),
    );
