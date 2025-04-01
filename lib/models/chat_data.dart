import 'package:mary/models/conversation.dart';

class ChatData {
  final String conversationId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String lastMessage;
  final ConversationRole lastMessageRole;
  final int messageCount;
  final String patientId;
  final String patientName;

  const ChatData({
    required this.conversationId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessage,
    required this.lastMessageRole,
    required this.messageCount,
    required this.patientId,
    required this.patientName,
  });

  factory ChatData.fromJSON(Map<String, dynamic> json) {
    return ChatData(
      conversationId:
          json.containsKey("conversation_id") ? json["conversation_id"] : "",
      title: json.containsKey("title") ? json["title"] : "",
      createdAt:
          json.containsKey("created_at")
              ? DateTime.parse(json["created_at"])
              : DateTime.now(),
      updatedAt:
          json.containsKey("last_updated")
              ? DateTime.parse(json["last_updated"])
              : DateTime.now(),
      lastMessage:
          json.containsKey("latest_message") ? json["latest_message"] : "",
      lastMessageRole:
          json.containsKey("latest_message_role")
              ? ConversationRole.values.firstWhere(
                (e) => e.name == json["latest_message_role"],
              )
              : ConversationRole.assistant,
      messageCount:
          json.containsKey("message_count")
              ? int.parse(json["message_count"].toString())
              : 0,
      patientId: json.containsKey("patient_id") ? json["patient_id"] : "",
      patientName: json.containsKey("patient_name") ? json["patient_name"] : "",
    );
  }
}