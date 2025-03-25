enum ConversationRole { 
  user("user"), 
  assistant("assistant");

  final String name;

  const ConversationRole(this.name); 
}

class Conversation {
  List<ConversationPiece> data;

  Conversation(this.data);

  factory Conversation.fromJSON(List json) {
    return Conversation(json.map((e) =>
      ConversationPiece.fromJSON(e)
    ).toList());
  }
}

class ConversationPiece {
  final ConversationRole role;
  final String content;

  ConversationPiece({required this.role, required this.content});

  factory ConversationPiece.fromJSON(Map<String,dynamic> json){
    return ConversationPiece(
      role: ConversationRole.values.any((e) => e.name == json["role"]) ? ConversationRole.values.firstWhere((e) => e.name == json["role"]) : ConversationRole.user,
      content: json.containsKey("content") ? json["content"] : "",
    );
  }
}