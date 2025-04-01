import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mary/constants/constants.dart';
import 'package:mary/models/conversation.dart';
import 'package:mary/models/chat_data.dart';
import 'package:mary/services/api_service_provider.dart';

@immutable
class RecentChatData {
  final List<ChatData> recentChats;
  final String? error;
  // final String? selectedChat;
  final bool isLoading;

  RecentChatData({
    required this.recentChats,
    required this.error,
    // required this.selectedChat,
    required this.isLoading,
  });

  RecentChatData copyWith({
    List<ChatData>? recentChats,
    String? error,
    // String? selectedChat,
    bool? isLoading,
  }) {
    return RecentChatData(
      recentChats: recentChats ?? this.recentChats,
      error: error ?? this.error,
      // selectedChat: selectedChat ?? this.selectedChat,
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
          // selectedChat: null,
          isLoading: false,
        ),
      );

  String? error;

  fetchConversations() async {
    state.copyWith(error: null, isLoading: true);
    try {
      List<dynamic> response = await ApiService().getRequest(
        AppConstants().conversationList,
      );
      List<ChatData> recentChatData =
          response.map((e) => ChatData.fromJSON(e)).toList();
      state = state.copyWith(
        recentChats: recentChatData,
        isLoading: false,
        // selectedChat: null,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  show() {
    print(state.recentChats.length);
  }
}

final StateNotifierProvider<RecentChatNotifier, RecentChatData>
recentChatProvider = StateNotifierProvider<RecentChatNotifier, RecentChatData>(
  (ref) => RecentChatNotifier(),
);
