import 'package:chat_app/functions/helper.dart';

class LastMessage {
  String? content;
  DateTime? time;
  bool? isRead;
  String? senderId;

  LastMessage({this.content, this.time, this.isRead, this.senderId});

  Map<String, dynamic> toJson() {
    if (content != null) {
      return {
        'content': content,
        'time': convertDateTimetoTomestamp(time),
        'is_read': isRead,
        'sender_id': senderId
      };
    } else {
      return {};
    }
  }

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      content: json['content'],
      time: convertTimestamptoDatetime(json['time']),
      isRead: json['is_read'],
      senderId: json['sender_id']
    );
  }
}

class RecentChats {
  String? uid;
  List<String>? toUids;

  RecentChats({this.uid, this.toUids});

  RecentChats.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    toUids = json['to_uids'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['to_uids'] = toUids;
    return data;
  }
}