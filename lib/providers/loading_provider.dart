import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:mary/routing/routes.dart";

@immutable
class LoadingInfo {
  const LoadingInfo({required this.isLoading, this.loadingMsg});

  final bool isLoading;
  final String? loadingMsg;

  LoadingInfo copyWith({bool? isLoading, String? loadingMsg}) {
    return LoadingInfo(
      isLoading: isLoading ?? this.isLoading,
      loadingMsg: loadingMsg ?? this.loadingMsg,
    );
  }
}

class LoadingNotifier extends StateNotifier<LoadingInfo> {
  LoadingNotifier() : super(LoadingInfo(isLoading: false));

  toggleLoading(bool? loading, String? loadingMsg) {
    if (loading != null) {
      if (loading) {
        _pushLoading(loadingMsg);
      } else {
        _popLoading();
      }
    } else {
      if (state.isLoading) {
        _popLoading();
      } else {
        _pushLoading(loadingMsg);
      }
    }
  }

  _pushLoading(String? loadingMsg) {
    if (!state.isLoading) {
      if (navKey.currentContext != null) {
        state = LoadingInfo(isLoading: true, loadingMsg: loadingMsg);
        showDialog(
          context: navKey.currentContext!,
          builder: (context) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(),
                  ),
                  if (loadingMsg != null)
                    Flexible(
                      child: Text(
                        loadingMsg,
                        style: TextStyle(color: Color(0xFFFFFFFF)),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      }
    }
  }

  _popLoading() {
    if (state.isLoading) {
      if (navKey.currentContext != null) {
        navKey.currentContext!.pop();
        state = LoadingInfo(isLoading: false, loadingMsg: null);
      }
    }
  }
}

final loadingProvider = StateNotifierProvider<LoadingNotifier, LoadingInfo>(
  (ref) => LoadingNotifier(),
);
