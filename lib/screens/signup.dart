import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chatScreen.dart';
import 'package:shatchat/services/auth.dart';
import 'package:shatchat/services/firestore.dart';
import 'package:shatchat/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class SignUp extends StatefulWidget {
  final Function toggle;
  SignUp(this.toggle);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  static String email;
  static String password;

  final Auth authh = new Auth();
  Users currentuser = new Users();
  String userid;
  final FireStoreMethos firestore = new FireStoreMethos();

  final _passwordController = TextEditingController();

  final TextEditingController username = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    Future<void> _submit() async {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

        authh.signUp(email, password, username.text).then((value) {
          Map<String, String> userInfo = {
            "name": username.text,
            "email": email,
          };

          currentuser = authh.currentUser(_auth.currentUser);
          userid = currentuser.userId;

          firestore.uploadinfo(userInfo, userid);

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (ctx) => ChatScreen()));
        });
      }
    }

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
                children: [
                  Container(
                    width: deviceWidth,
                    height: deviceHeight * 0.3,
                    color: Colors.transparent,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 115,
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
                    padding: const EdgeInsets.all(20),
                    child: Card(
                      color: Color(0xffe9f3ee),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      elevation: 8.0,
                      shadowColor: Color(0xff7cdea2),
                      child: Container(
                        height: deviceHeight * 0.55,
                        padding: const EdgeInsets.all(15),
                        child: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextFormField(
                                    controller: username,
                                    validator: (value) {
                                      if (value.isEmpty || value.length < 3) {
                                        return 'Invalid username!';
                                      }
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'Username',
                                        prefixIcon: Icon(
                                          Icons.person,
                                          color: Color(0xff45b591),
                                        )),
                                  ),
                                  TextFormField(
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
                                    onSaved: (value) {
                                      email = value;
                                    },
                                  ),
                                  TextFormField(
                                    controller: _passwordController,
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
                                    onSaved: (value) {
                                      password = value;
                                    },
                                  ),
                                  TextFormField(
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        labelText: 'Confirm Password',
                                        prefixIcon: Icon(
                                          Icons.lock,
                                          color: Color(0xff45b591),
                                        )),
                                    validator: (value) {
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match!';
                                      }
                                    },
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Container(
                                        child: Column(
                                          children: [
                                            FlatButton(
                                              minWidth: 190,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              color: Color(0xff5ad1a4),
                                              onPressed: _submit,
                                              child: Text(
                                                'Sign up',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            // FlatButton(
                                            //     shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(
                                            //               15.0),
                                            //     ),
                                            //     color: Color(0xff5ad1a4),
                                            //     onPressed: () {
                                            //       authh
                                            //           .signInwithGoogle()
                                            //           .then((value) {
                                            //         Navigator.pushReplacement(
                                            //             context,
                                            //             MaterialPageRoute(
                                            //                 builder: (ctx) =>
                                            //                     ChatRoom()));
                                            //       });
                                            //     },
                                            //     child: Container(
                                            //       width: 160,
                                            //       child: Row(
                                            //         mainAxisAlignment:
                                            //             MainAxisAlignment
                                            //                 .center,
                                            //         children: [
                                            //           Text(
                                            //             'Sign up with Gmail',
                                            //             style: TextStyle(
                                            //                 color:
                                            //                     Colors.white),
                                            //           ),
                                            //           Image(
                                            //             image: AssetImage(
                                            //               'assets/images/Gmail-logo.png',
                                            //             ),
                                            //             width: 35,
                                            //             height: 35,
                                            //           )
                                            //         ],
                                            //       ),
                                            //     )),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text('Already have account? '),
                                                InkWell(
                                                  onTap: widget.toggle,
                                                  // Navigator.push(
                                                  //     context,
                                                  //     MaterialPageRoute(
                                                  //         builder: (ctx) =>
                                                  //             SignIn(widget
                                                  //                 .toggle)));

                                                  child: Text(
                                                    'Sign in now',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff256150),
                                                        decoration:
                                                            TextDecoration
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
                              ),
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