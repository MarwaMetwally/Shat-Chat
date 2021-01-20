import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shatchat/services/firestore.dart';

class Auth {
  auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  FireStoreMethos _fireStoreMethos = new FireStoreMethos();
  String username;
  GoogleSignIn _googleSignIn = GoogleSignIn(
      // scopes: [
      //   'https://www.googleapis.com/auth/contacts.readonly',
      // ],
      );
  bool google = false;

  // Users currentUser(auth.User user) {
  //   return user != null
  //       ? Users(
  //           userId: user.uid,
  //         )
  //       : null;
  // }

  Future<String> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      auth.User user = result.user;
      return user.uid;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> signUp(String email, String password, String name) async {
    username = name;
    final result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    auth.User user = result.user;
    return user.uid;
  }

  Future resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
    }
  }

  Future signOut() async {
    try {
      await _auth.signOut().then((value) => _googleSignIn.signOut());
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> signInwithGoogle() async {
    try {
      final googleSignInAccount = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final auth.UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final auth.User user = authResult.user;

      if (user != null) {
        print('testtttt ${user.uid}');
        print('testtttt email ${user.email}');
        print('testtttt usename ${user.displayName}');
        Map<String, dynamic> userInfo = {
          "name": user.displayName,
          "email": user.email,
          "photo": user.photoURL,
          "status": true,
          "phone": ""
        };
        final result = await FirebaseFirestore.instance
            .collection("users")
            .where("email", isEqualTo: user.email)
            .get();

        if (result.docs.length == 0) {
          try {
            _fireStoreMethos.uploadinfo(userInfo, user.uid);
          } catch (e) {
            print(e.toString());
          }
        }
        google = true;

        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);

        final auth.User currentUser = _auth.currentUser;
        assert(user.uid == currentUser.uid);
      }
    } catch (error) {
      print('erorrrrrrrrrr${error.toString()}');
    }
  }
}
