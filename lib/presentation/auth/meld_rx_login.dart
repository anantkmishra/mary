import "dart:developer" as dev;

import "package:flutter/material.dart";
import "package:flutter_inappwebview/flutter_inappwebview.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:mary/constants/constants.dart";
import "package:mary/providers/meld_rx_provider.dart";
import "package:mary/routing/router.dart";
import "package:mary/routing/routes.dart";
// import "package:mary/routing/routes.dart";
import "package:mary/style/style.dart";
// import "package:webview_flutter/webview_flutter.dart";

class MeldRxLogin extends ConsumerStatefulWidget {
  const MeldRxLogin({super.key});

  @override
  ConsumerState<MeldRxLogin> createState() => _MeldRxLoginState();
}

class _MeldRxLoginState extends ConsumerState<MeldRxLogin> {
  // late final WebViewController _controller;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   dev.log(maryAppRouter.state.fullPath ?? "", name: "PATH ");
  //   WidgetsBinding.instance.addPostFrameCallback((t) {
  //     final provider = ref.read(meldRxProvider.notifier);
  //     provider.init();
  //     // provider.initAuthURL();
  //     // provider.initController();
  //   });
  // }
  //https://mary.seecole.app/callback?code=

  late InAppWebViewController _inAppWebViewController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      ref.read<MeldRxNotifier>(meldRxProvider.notifier).initAuthURL();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(meldRxProvider);
    return SafeArea(
      child: Scaffold(
        body:
            !provider.isAuthURLInitialized
                ? Center(child: CircularProgressIndicator())
                : InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(AppConstants().authURL ?? ""),
                  ),
                  onWebViewCreated: (InAppWebViewController controller) {
                    _inAppWebViewController = controller;
                  },

                  onLoadStart: (controller, url) {
                    // isLoading.value = true;
                    if (url != null) {
                      if (url.rawValue.startsWith(
                        "https://mary.seecole.app/callback?code=",
                      )) {
                        ref
                            .read<MeldRxNotifier>(meldRxProvider.notifier)
                            .fetchToken(url.rawValue);
                      }
                    }
                  },

                  // onLoadStop: (controller, url) {
                  //   isLoading.value = false;
                  // },
                ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     navigateTo(MaryAppRoutes.home);
        //   },
        // ),
      ),
    );

    // if (provider.error != null) {
    //   Scaffold(
    //     body: Center(
    //       child: Text(provider.error!, style: MaryStyle().white20w500),
    //     ),
    //   );
    // }
    // if (!provider.isControllerInitialized) {
    //   return Scaffold(body: Center(child: CircularProgressIndicator()));
    // }
    // if (provider.controller != null) {
    //   return Scaffold(
    //     // body: WebView(),
    //     body: WebViewWidget(controller: provider.controller!),
    //   );
    // }
    // return Scaffold(body: Center(child: Text("Something went wrong!!!")));
  }
}
