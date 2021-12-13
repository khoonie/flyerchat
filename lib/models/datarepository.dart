import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flyerchat/models/chatitem.dart';

class DataRepository {
  // top level reference is pets
  final CollectionReference<Map<String, dynamic>> collection = FirebaseFirestore
      .instance
      .collection('rooms'); // there will be rooms, messages, users

  // snapshots method to get a stream of snapshots, listens for updates
  Stream<QuerySnapshot<Map<String, dynamic>>> getStream() {
    return collection.snapshots();
  }

  // add new room, returns Future if waiting for result; will auto create new document id for ChatItem
  Future<DocumentReference> addChatItem(ChatItem ci) {
    return collection.add(ci.toJson());
  }

  // Update ChatItem class
  updateHome(ChatItem ci) async {
    await collection.doc(ci.reference?.id).update(ci.toJson());
  }
}
