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

  Stream friends(String me) {
    return FirebaseFirestore.instance
        .collection("chatroom")
        .where("users", arrayContains: me)
        .snapshots();
  }

  Future<String> getUserPhoto(String id) {
    DocumentReference ref =
        FirebaseFirestore.instance.collection("users").doc(id);

    return ref.get().then((value) => value.data()["photo"]);
  }

  Future<String> getUserName(String id) {
    DocumentReference ref =
        FirebaseFirestore.instance.collection("users").doc(id);

    return ref.get().then((value) => value.data()["name"]);
  }

  Future<String> getUserPhone(String id) {
    DocumentReference ref =
        FirebaseFirestore.instance.collection("users").doc(id);

    return ref.get().then((value) => value.data()["phone"]);
  }

  Future<String> getUserEmail(String id) {
    DocumentReference ref =
        FirebaseFirestore.instance.collection("users").doc(id);

    return ref.get().then((value) => value.data()["email"]);
  }

  uploadinfo(Map<String, dynamic> userdata, String userId) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set(userdata)
        .catchError((e) {
      print('erorr ${e.toString()}');
    });
  }

  uploadUserData(String userId, String phone, String newName) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({"phone": phone, "name": newName});
  }

  uploadUserPhoto(
    String photo,
    String userId,
  ) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({"photo": photo});
  }

  upateReact(bool liked, String chatroomId, String docId) {
    FirebaseFirestore.instance
        .collection('chatroom')
        .doc(chatroomId)
        .collection('messages')
        .doc(docId)
        .update({"liked": liked});
  }

  updateStatus(
    bool isonline,
    String userID,
  ) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .update({"status": isonline});
  }

  createChatRoom(String chatroomId, chatMap, roomMap) {
    FirebaseFirestore.instance
        .collection("chatroom")
        .doc(chatroomId)
        .set(roomMap)
        .then((value) => FirebaseFirestore.instance
            .collection("chatroom")
            .doc(chatroomId)
            .collection("messages")
            .doc()
            .set(chatMap));
  }

  Stream getMessages(String roomId) {
    return FirebaseFirestore.instance
        .collection("chatroom")
        .doc(roomId)
        .collection("messages")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Stream getfriends(String email) {
    return FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .snapshots();
  }

  Stream getLastMessage(String roomId) {
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

  Future updatePassword() {}
}
