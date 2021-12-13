import 'package:cloud_firestore/cloud_firestore.dart';

class ChatItem {
  String name = '';
  String photoUrl = '';
  DocumentReference? reference;

  ChatItem(this.name, this.photoUrl, [this.reference]);

  factory ChatItem.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    ChatItem newChatItem = ChatItem.fromJson(snapshot.data()!);
    newChatItem.reference = snapshot.reference;
    return newChatItem;
  }

  factory ChatItem.fromJson(Map<String, dynamic> json) =>
      chat_item_from_json(json);

  Map<String, dynamic> toJson() => chat_item_to_json(this);
  //@override
  //String toString() => "ChatItem<$address>";
}

ChatItem chat_item_from_json(Map<String, dynamic> json) {
  return ChatItem(json['name'] as String, json['photoUrl'] as String);
}

Map<String, dynamic> chat_item_to_json(ChatItem instance) =>
    <String, dynamic>{'name': instance.name, 'photoUrl': instance.photoUrl};
