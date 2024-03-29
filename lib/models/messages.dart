import 'package:chat_app/functions/helper.dart';

class Message {
  String messageId;
  String senderId;
  String content;
  DateTime sentAt;
  String type;
  bool seen;
  DateTime? seenAt;

  Message(
      {required this.messageId,
      required this.senderId,
      required this.content,
      required this.sentAt,
      this.type = 'text',
      this.seen = false,
      this.seenAt});

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'sender_id': senderId,
      'content': content,
      'sent_at': sentAt,
      'type': type,
      'seen': seen,
      'seen_at': seenAt
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
        seenAt: json['seen_at'] == null
            ? null
            : convertTimestamptoDatetime(json['seen_at']));
  }
}
