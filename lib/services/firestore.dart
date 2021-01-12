import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreMethos {
  Future<List<QueryDocumentSnapshot>> getUserByUserName() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("users").get();
    return querySnapshot.docs;
  }

  Future getAllUsers() async {
    return await FirebaseFirestore.instance.collection("users").get();
  }

  getUserPhoto(String id) {
    String photo;
    DocumentReference ref =
        FirebaseFirestore.instance.collection("users").doc(id);
    ref.get().then((value) => photo = value.data()["photo"]);

    return photo;
  }

  uploadinfo(Map<String, String> userdata, String userId) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set(userdata)
        .catchError((e) {
      print('erorr ${e.toString()}');
    });
  }

  createChatRoom(String chatroomId, chatMap) {
    FirebaseFirestore.instance
        .collection("chatroom")
        .doc(chatroomId)
        .collection("messages")
        .doc()
        .set(chatMap);
  }

  Stream getMessages(String roomId) {
    return FirebaseFirestore.instance
        .collection("chatroom")
        .doc(roomId)
        .collection("messages")
        .orderBy("time", descending: true)
        .snapshots();
  }

  String getDocID(String user1, String user2) {
    if (user1.substring(0, 1).codeUnitAt(0) >
        user2.substring(0, 1).codeUnitAt(0)) {
      return "$user2\-$user1";
    } else {
      return "$user1\-$user2";
    }
  }
}
