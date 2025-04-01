import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mary/constants/constants.dart';
import 'package:mary/models/conversation.dart';
import 'package:mary/services/api_service_provider.dart';

@immutable
class PreviousChatData {
  final Conversation conversation;
  final String? error;
  final bool isLoading;

  const PreviousChatData({
    required this.conversation,
    required this.error,
    required this.isLoading,
  });

  PreviousChatData copyWith({
    Conversation? conversation,
    String? error,
    bool? isLoading,
  }) {
    String? err;
    if (error != null && error == "null") {
      err = null;
    } else {
      err = error ?? this.error;
    }

    return PreviousChatData(
      conversation: conversation ?? this.conversation,
      error: err,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PreviousChatNotifier extends StateNotifier<PreviousChatData> {
  PreviousChatNotifier()
    : super(
        PreviousChatData(
          conversation: Conversation(<ConversationPiece>[]),
          isLoading: false,
          error: null,
        ),
      );

  fetchConversation(String id) async {
    state = state.copyWith(isLoading: true, error: "null");

    try {
      List<dynamic> conversation = await ApiService().getRequest(
        "${AppConstants().conversation}/$id",
      );
      Conversation c = Conversation(
        conversation.map((e) => ConversationPiece.fromJSON(e)).toList(),
      );
      state = state.copyWith(conversation: c, isLoading: false, error: "null");
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  clearChat() {
    state = state.copyWith(
      conversation: Conversation(<ConversationPiece>[]),
      error: "null",
      isLoading: false,
    );
  }
}

final StateNotifierProvider<PreviousChatNotifier, PreviousChatData>
previousChatProvider =
    StateNotifierProvider<PreviousChatNotifier, PreviousChatData>(
      (ref) => PreviousChatNotifier(),
    );
