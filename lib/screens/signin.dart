import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shatchat/screens/profile.dart';
import 'chatScreen.dart';
import 'package:shatchat/services/firestore.dart';
import 'package:shatchat/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignIn extends StatefulWidget {
  final Function toggle;
  SignIn(this.toggle);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formkey = GlobalKey();

  final TextEditingController email = TextEditingController();

  final TextEditingController password = TextEditingController();
  String senderPhoto;
  final Auth auth = new Auth();
  FireStoreMethos _fireStoreMethos = new FireStoreMethos();
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _submit() async {
    if (_formkey.currentState.validate()) {
      _formkey.currentState.save();
      await auth.signIn(email.text, password.text).then((value) async {
        senderPhoto =
            await _fireStoreMethos.getUserPhoto(_auth.currentUser.uid);
        print(senderPhoto);
        return Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (ctx) => ChatScreen(senderPhoto)));
      });

      // senderPhoto = await _fireStoreMethos
      //     .getUserPhoto(_auth.currentUser.uid)
      //     .then((value) {
      //   print(senderPhoto);
      //   // return Navigator.pushReplacement(context,
      //   //     MaterialPageRoute(builder: (ctx) => ChatScreen(senderPhoto)));
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          body: SafeArea(
        child: Container(
            width: deviceWidth,
            height: deviceHeight,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/background.jpg'),
                    fit: BoxFit.cover)),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: deviceWidth,
                    height: deviceHeight * 0.35,
                    color: Colors.transparent,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 115,
                          bottom: 10,
                          child: Image(
                            image: AssetImage(
                              'assets/images/chatLogo.png',
                            ),
                            width: deviceWidth * 0.35,
                            height: deviceHeight * 0.35,
                          ),
                        ),
                        Positioned(
                          top: 180,
                          left: 115,
                          child: Text(
                            'Shat Chat',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Card(
                      color: Color(0xffe9f3ee),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      elevation: 8.0,
                      shadowColor: Color(0xff7cdea2),
                      child: Container(
                        height: deviceHeight * 0.51,
                        padding: const EdgeInsets.all(15),
                        child: Form(
                            key: _formkey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TextFormField(
                                  controller: email,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: Color(0xff45b591),
                                      )),
                                  validator: (value) {
                                    if (value.isEmpty || !value.contains('@')) {
                                      return 'Invalid email!';
                                    }
                                  },
                                ),
                                TextFormField(
                                  controller: password,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Color(0xff45b591),
                                      )),
                                  validator: (value) {
                                    if (value.isEmpty || value.length < 6) {
                                      return ' password too short !';
                                    }
                                  },
                                ),
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text('Forgot Password ?'),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      child: Column(
                                        children: [
                                          FlatButton(
                                            minWidth: 180,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            color: Color(0xff5ad1a4),
                                            onPressed: _submit,
                                            child: Text(
                                              'Sign in',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          FlatButton(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              color: Color(0xff5ad1a4),
                                              onPressed: () async {
                                                await auth.signInwithGoogle().then(
                                                    (value) => Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (ctx) =>
                                                                ChatScreen(_auth
                                                                    .currentUser
                                                                    .photoURL))));

                                                print('sendr$senderPhoto');
                                              },
                                              child: Container(
                                                width: 150,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Sign in with Gmail',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    Image(
                                                      image: AssetImage(
                                                        'assets/images/Gmail-logo.png',
                                                      ),
                                                      width: 35,
                                                      height: 35,
                                                    ),
                                                  ],
                                                ),
                                              )),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text('Don\'t have account? '),
                                              GestureDetector(
                                                onTap: widget.toggle,
                                                child: Text(
                                                  'Register now',
                                                  style: TextStyle(
                                                      color: Color(0xff256150),
                                                      decoration: TextDecoration
                                                          .underline),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )),
                      ),
                    ),
                  )
                ],
              ),
            )),
      )),
    );
  }
}
