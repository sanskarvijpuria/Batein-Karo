import 'package:batein_karo/functions/helper.dart';
import 'package:batein_karo/models/messages.dart';

class Group {
  String groupId;
  String groupName;
  String creatorId;
  DateTime createdAt;
  List<String> members;
  List<Message> messages;

  Group({
    required this.groupId,
    required this.groupName,
    required this.creatorId,
    required this.createdAt,
    required this.members,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'creatorId': creatorId,
      'createdAt': createdAt,
      'members': members,
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupId: json['groupId'],
      groupName: json['groupName'],
      creatorId: json['creatorId'],
      createdAt: convertTimestamptoDatetime(json['createdAt']),
      members: List<String>.from(json['members']),
      messages: (json['messages'] as List)
          .map((message) => Message.fromJson(message))
          .toList(),
    );
  }
}
