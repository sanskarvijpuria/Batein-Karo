import 'package:chat_app/models/messages.dart';



class Chat {
  String chatId; // Will be hash of two UIDs.
  String type;
  List<String> participants;
  List<Message>? messages;

  Chat({
    required this.chatId,
    required this.type,
    required this.participants,
    this.messages,
  });

  Map<String, dynamic> toJson() {
    if (messages != null) {
      return {
        'chatId': chatId,
        'type': type,
        'participants': participants,
        'messages': messages!.map((message) => message.toJson()).toList(),
      };
    } else {
      return {
        'chatId': chatId,
        'type': type,
        'participants': participants,
      };
    }
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      chatId: json['chatId'],
      type: json['type'],
      participants: List<String>.from(json['participants']),
      messages: (json['messages'] as List)
          .map((message) => Message.fromJson(message))
          .toList(),
    );
  }
}
