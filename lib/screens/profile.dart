import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:shatchat/services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shatchat/screens/chatScreen.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String phone;
  final String photo;
  final bool sender;
  ProfileScreen({this.phone, this.userName, this.photo, this.sender});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final picker = ImagePicker();
  File _image;
  String imageUrl;

  bool editName = false;
  bool editPhone = false;
  bool photoloading = false;
  FireStoreMethos _fireStoreMethos = new FireStoreMethos();
  FirebaseAuth _auth = FirebaseAuth.instance;
  String currentuserId;
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  @override
  void initState() {
    name.text = widget.userName;
    phone.text = widget.phone;

    imageUrl = widget.photo;

    super.initState();
  }

  Future<void> uploadImageToFirebase() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
    if (_image != null) {
      String fileName = path.basename(_auth.currentUser.uid);

      storage.Reference firebaseStorageRef =
          storage.FirebaseStorage.instance.ref().child(fileName);

      storage.UploadTask uploadTask = firebaseStorageRef.putFile(_image);

      // await (await uploadTask).ref.getDownloadURL().then((value) {
      //   setState(() {
      //     print("Done: $value");
      //     imageUrl = value;
      //   });
      setState(() {
        photoloading = true;
      });
      storage.TaskSnapshot taskSnapshot = await uploadTask;
      taskSnapshot.ref.getDownloadURL().then((value) {
        setState(() {
          print("Done: $value");

          imageUrl = _image == null
              ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR-mHFh8u6UvSXY3spw5oHgyZHKNmNOdgFJ9w&usqp=CAU'
              : value;
          print(phone.text);
          print(name.text);
          _fireStoreMethos.uploadUserPhoto(imageUrl, _auth.currentUser.uid);
          setState(() {
            photoloading = false;
          });
          // return value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Profile"),
      //   backgroundColor: Colors.white,
      // ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.4), BlendMode.dstATop),
                image: _image == null
                    ? NetworkImage(widget.photo)
                    : FileImage(
                        _image,
                      ),
                fit: BoxFit.fill)),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: SingleChildScrollView(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back,
                        size: 30, color: Theme.of(context).accentColor),
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 230,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 100,
                        backgroundImage: _image == null
                            ? NetworkImage(widget.photo)
                            : FileImage(_image),
                        child: widget.photo == null
                            ? Image.network(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdMCPi6SVnch4j_K57TF_XBbFmYuPGaMzOPQ&usqp=CAU')
                            : null,
                      ),
                    ),
                    widget.sender
                        ? Positioned(
                            top: 170,
                            left: 120,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Theme.of(context).accentColor,
                              child: IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.camera,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    await uploadImageToFirebase();

                                    // print('userid $userid');
                                  }),
                            ))
                        : Container(),

                    //   Icon(Icons.camera)
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Card(
                  color: Color(0xffe9f3ee).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 8.0,
                  shadowColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(15),
                      width: 400,
                      height: 300,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(FontAwesomeIcons.user),
                              editName
                                  ? Expanded(
                                      child: TextField(
                                        cursorColor:
                                            Theme.of(context).accentColor,
                                        controller: name,
                                        //  autofocus: true,
                                        //  enabled: false,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            //  borderRadius: BorderRadius.circular(20),
                                          ),

                                          hintText: "Name",
                                          // prefixIcon: Icon(FontAwesomeIcons.user),
                                          //    suffixIcon: Icon(Icons.edit)
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 25),
                                        child: Container(
                                          child: Text(widget.userName),
                                        ),
                                      ),
                                    ),
                              widget.sender
                                  ? GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          editName = true;
                                        });
                                      },
                                      child: Icon(Icons.edit))
                                  : Container()
                            ],
                          ),
                          Divider(
                            indent: 50,
                            thickness: 1,
                            color: Theme.of(context).accentColor,
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Row(
                            //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(FontAwesomeIcons.phone),
                              editPhone
                                  ? Expanded(
                                      child: TextField(
                                        cursorColor:
                                            Theme.of(context).accentColor,

                                        controller: phone,
                                        keyboardType: TextInputType.number,
                                        //  autofocus: true,
                                        //  enabled: false,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            //  borderRadius: BorderRadius.circular(20),
                                          ),

                                          hintText: "Phone",
                                          // prefixIcon: Icon(FontAwesomeIcons.user),
                                          //    suffixIcon: Icon(Icons.edit)
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 25),
                                        child: Container(
                                          child: Text(widget.phone),
                                        ),
                                      ),
                                    ),
                              widget.sender
                                  ? GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          editPhone = true;
                                        });
                                      },
                                      child: Icon(Icons.edit))
                                  : Container()
                            ],
                          ),
                          Divider(
                            indent: 50,
                            thickness: 1,
                            color: Theme.of(context).accentColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                widget.sender
                    ? Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: FlatButton(
                            minWidth: 100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            color: Color(0xff5ad1a4),
                            onPressed: () {
                              // setState(() {
                              //   isloading = true;
                              // });
                              _fireStoreMethos.uploadUserData(
                                  _auth.currentUser.uid, phone.text, name.text);

                              print(imageUrl);
                              // setState(() {
                              //   isloading = false;
                              // });
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (ctx) => ChatScreen()));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: photoloading
                                  ? CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                    )
                                  : Text(
                                      'Done',
                                      style: TextStyle(
                                        fontSize: 19,
                                        color: Colors.white,
                                      ),
                                    ),
                            )),
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
