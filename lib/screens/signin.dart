import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shatchat/screens/signup.dart';
import 'chatScreen.dart';
import 'package:shatchat/services/firestore.dart';
import 'package:shatchat/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignIn extends StatefulWidget {
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
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_formkey.currentState.validate()) {
      _formkey.currentState.save();
      try {
        final userId =
            await auth.signIn(email.text, password.text).catchError((e) {
          print('errrrr ${e.toString()}');
          var errormsg = 'Authentication failed !';

          if (e.toString().toLowerCase().contains('INVALID_EMAIL')) {
            errormsg = 'This is not a valid email address';
          } else if (e.toString().toLowerCase().contains('WEAK_PASSWORD')) {
            errormsg = 'This password is too weak.';
          } else if (e.toString().contains('user-not-found')) {
            errormsg = 'Wrong Email.';
          } else if (e.toString().contains('wrong-password')) {
            errormsg = 'wrong-password.';
          }
          showErrorDialog(errormsg);
        });
        if (userId != null) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (ctx) => ChatScreen()));
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
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
          resizeToAvoidBottomInset: true,
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
                              left: 90,
                              child: SizedBox(
                                child: ColorizeAnimatedTextKit(
                                  text: [
                                    "Shat Chat",
                                  ],
                                  textStyle: TextStyle(
                                    fontSize: 40.0,
                                  ),
                                  colors: [
                                    Colors.white,
                                    Color(0xff45b591),
                                    Colors.grey,
                                  ],
                                  textAlign: TextAlign.start,
                                ),
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
                                        if (value.isEmpty ||
                                            !value.contains('@')) {
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
                                      child: GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                              isScrollControlled: true,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(25),
                                                    topRight:
                                                        Radius.circular(25)),
                                              ),
                                              backgroundColor: Colors.white,
                                              context: context,
                                              builder: (context) {
                                                String email;
                                                return AnimatedPadding(
                                                  duration: Duration(
                                                      milliseconds: 150),
                                                  curve: Curves.easeOut,
                                                  padding: EdgeInsets.only(
                                                      bottom:
                                                          MediaQuery.of(context)
                                                              .viewInsets
                                                              .bottom),
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.4,
                                                    padding: EdgeInsets.only(
                                                        top: 30,
                                                        right: 30,
                                                        left: 30),
                                                    decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Theme.of(context)
                                                                .accentColor
                                                                .withOpacity(
                                                                    0.3),
                                                            Theme.of(context)
                                                                .accentColor
                                                                .withOpacity(
                                                                    0.1),
                                                            Colors.white,
                                                          ],
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        25),
                                                                topRight: Radius
                                                                    .circular(
                                                                        25))),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        TextField(
                                                          // autofocus: true,
                                                          onChanged: (value) {
                                                            email = value;
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                                  hintText:
                                                                      'Your Email'),
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        FlatButton(
                                                            minWidth: 90,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15.0),
                                                            ),
                                                            color: Color(
                                                                0xff5ad1a4),
                                                            onPressed: () {
                                                              auth
                                                                  .resetPassword(
                                                                      email)
                                                                  .then((value) =>
                                                                      Navigator.pop(
                                                                          context));
                                                            },
                                                            child:
                                                                Text('reset'))
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Text('Forgot Password ?')),
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
                                                      BorderRadius.circular(
                                                          15.0),
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
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  color: Color(0xff5ad1a4),
                                                  onPressed: () async {
                                                    await auth
                                                        .signInwithGoogle()
                                                        .then((value) => _auth
                                                                    .currentUser
                                                                    .uid !=
                                                                null
                                                            ? Navigator.of(
                                                                    context)
                                                                .push(MaterialPageRoute(
                                                                    builder:
                                                                        (ctx) =>
                                                                            ChatScreen()))
                                                            : Navigator.of(
                                                                    context)
                                                                .push(MaterialPageRoute(
                                                                    builder:
                                                                        (ctx) =>
                                                                            SignIn()))
                                                                .catchError(
                                                                    (e) {
                                                                print(e);
                                                              }));

                                                    print('sendr$senderPhoto');
                                                  },
                                                  child: Container(
                                                    width: 150,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'Sign in with Gmail',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
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
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        SignUp()));
                                                      },
                                                      child: Text(
                                                        'Register now',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xff256150),
                                                            decoration:
                                                                TextDecoration
                                                                    .underline),
                                                      ),
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
