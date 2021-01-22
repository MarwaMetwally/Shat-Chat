import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profile.dart';
import 'package:shatchat/services/auth.dart';
import 'package:shatchat/services/firestore.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'signin.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController email = TextEditingController();

  final Auth authh = new Auth();

  String userid;
  final FireStoreMethos firestore = new FireStoreMethos();

  final _passwordController = TextEditingController();

  final TextEditingController username = TextEditingController();

  final TextEditingController phone = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

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
      auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        try {
          await authh
              .signUp(email.text, _passwordController.text, username.text)
              .catchError((e) {
            var errormsg = 'Authentication failed !';
            if (e.toString().contains('already in use')) {
              errormsg = 'This email address is already in use.';
            }
            showErrorDialog(errormsg);
          });

          Map<String, dynamic> userInfo = {
            "phone": phone.text,
            "name": username.text,
            "email": email.text,
            "photo":
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdMCPi6SVnch4j_K57TF_XBbFmYuPGaMzOPQ&usqp=CAU',
            "status": true
          };

          userid = _auth.currentUser.uid;

          firestore.uploadinfo(userInfo, userid);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (ctx) => ProfileScreen(
                        photo:
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdMCPi6SVnch4j_K57TF_XBbFmYuPGaMzOPQ&usqp=CAU',
                        sender: true,
                        userName: username.text,
                        phone: phone.text,
                      )));
        } catch (e) {
          print('eeeee$e');
        }
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
                                    onSaved: (value) {
                                      email.text = value;
                                    },
                                  ),
                                  TextFormField(
                                    controller: phone,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        labelText: 'Phone',
                                        prefixIcon: Icon(
                                          Icons.phone,
                                          color: Color(0xff45b591),
                                        )),
                                    onSaved: (value) {
                                      phone.text = value;
                                    },
                                    validator: (value) {
                                      if (value.isEmpty || value.length < 11) {
                                        return 'Invalid phone number !';
                                      }
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
                                      _passwordController.text = value;
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
                                              onPressed: () {
                                                _submit();
                                                // Navigator.pushReplacement(
                                                //     context,
                                                //     MaterialPageRoute(
                                                //         builder: (ctx) =>
                                                //             ProfileScreen(
                                                //                 userid)));
                                              },
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
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (ctx) =>
                                                                SignIn()));
                                                  },
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
