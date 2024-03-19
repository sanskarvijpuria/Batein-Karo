import 'package:chat_app/functions/helper.dart';

class ChatUser {
  ChatUser({
    required this.uid,
    required this.userImage,
    required this.userName,
    required this.email,
    required this.name,
    required this.about,
    required this.createdAt,
    required this.isOnline,
    required this.lastActive,
    required this.pushToken,
  });
  late final String uid;
  late final String userImage;
  late final String userName;
  late final String email;
  late final String name;
  late final String about;
  late final DateTime? createdAt;
  late final bool? isOnline;
  late final DateTime? lastActive;
  late final String pushToken;
  
  ChatUser.fromJson(Map<String, dynamic> json){
    uid = json['uid'];
    userImage = json['user_image'] ?? '';
    userName = json['user_name'] ?? '';
    email = json['email'] ?? '';
    name = json['name'] ?? '';
    about = json['about'] ?? '';
    createdAt = json['created_at']  == null ? null : convertTimestamptoDatetime( json['created_at'] );
    isOnline = json['is_online'];
    lastActive =  json['last_active']  == null ? null : convertTimestamptoDatetime( json['crealast_activeted_at'] );
    pushToken = json['push_token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['user_image'] = userImage;
    data['user_name'] = userName;
    data['email'] = email;
    data['name'] = name;
    data['about'] = about;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['last_active'] = lastActive;
    data['push_token'] = pushToken;
    return data;
  }
}