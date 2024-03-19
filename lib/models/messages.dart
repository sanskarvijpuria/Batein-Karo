import 'package:chat_app/functions/helper.dart';

class Message {
  String messageId;
  String senderId;
  String content;
  DateTime sentAt;
  String type;
  bool seen;

  Message({
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    this.type = 'text',
    this.seen = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'sender_id': senderId,
      'content': content,
      'sent_at': sentAt,
      'type': type,
      'seen': seen,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['message_id'] ?? ' ',
      senderId: json['sender_id'],
      content: json['content'],
      sentAt: convertTimestamptoDatetime(json['sent_at']),
      type: json['type'],
      seen: json['seen'] ?? false,
    );
  }
}