import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mary/constants/constants.dart';
import 'package:mary/models/chat_data.dart';
import 'package:mary/services/api_service_provider.dart';

@immutable
class RecentChatData {
  final List<ChatData> recentChats;
  final String? error;
  final bool isLoading;

  const RecentChatData({
    required this.recentChats,
    required this.error,
    required this.isLoading,
  });

  RecentChatData copyWith({
    List<ChatData>? recentChats,
    String? error,
    bool? isLoading,
  }) {
    return RecentChatData(
      recentChats: recentChats ?? this.recentChats,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RecentChatNotifier extends StateNotifier<RecentChatData> {
  RecentChatNotifier()
    : super(
        RecentChatData(
          recentChats: <ChatData>[],
          error: null,
          isLoading: false,
        ),
      );

  String? error;

  fetchConversations() async {
    state = state.copyWith(error: null, isLoading: true);
    try {
      List<dynamic> response = await ApiService().getRequest(
        AppConstants().conversationList,
        checkConnectivity: true,
      );
      List<ChatData> recentChatData =
          response.map((e) => ChatData.fromJSON(e)).toList();
      state = state.copyWith(
        recentChats: recentChatData,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final StateNotifierProvider<RecentChatNotifier, RecentChatData>
recentChatProvider = StateNotifierProvider<RecentChatNotifier, RecentChatData>(
  (ref) => RecentChatNotifier(),
);