import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/auth/login_page.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final ChatUser user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile Page",
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10.0, right: 10.0),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.red[500],
            elevation: 2,
            onPressed: () async {
              Dialogs.showProgressBar(context);
              API.updateActiveStatus(false);
              await API.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  API.auth = FirebaseAuth.instance;
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => LoginPage()));
                });
              });
            },
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            label: Text("Log Out",
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * 0.1),
                              child: Image.file(
                                File(_image!),
                                width: mq.height * 0.2,
                                height: mq.height * 0.2,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * 0.1),
                              child: CachedNetworkImage(
                                width: mq.height * 0.2,
                                height: mq.height * 0.2,
                                fit: BoxFit.cover,
                                imageUrl: widget.user.image,
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(
                                  child: Icon(CupertinoIcons.person),
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: -5,
                        right: -5,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: () {
                            showBottomSheet();
                          },
                          shape: CircleBorder(),
                          color: Colors.white,
                          child: Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: mq.height * 0.03,
                  ),
                  Text(
                    widget.user.email,
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(
                    height: mq.height * 0.05,
                  ),
                  TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => API.myInfo.name = val ?? "",
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : "Field Required",
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: "Enter Name",
                        label: Text("Name"),
                      )),
                  SizedBox(
                    height: mq.height * 0.02,
                  ),
                  TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => API.myInfo.about = val ?? "",
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : "Field Required",
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.info,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: "Enter About",
                        label: Text("About"),
                      )),
                  SizedBox(
                    height: mq.height * 0.05,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: StadiumBorder(),
                        minimumSize: Size(mq.width * 0.4, mq.height * 0.06)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        API.updateUser().then((value) {
                          FocusScope.of(context).unfocus();
                          Dialogs.showSnackBar(
                              context, "Profile Updated Successfully");
                        });
                      }
                    },
                    icon: Icon(
                      Icons.edit,
                      size: 28,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Update",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
                top: mq.height * 0.03, bottom: mq.height * 0.05),
            children: [
              Text(
                "Pick a Profile Image",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: mq.height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: CircleBorder(),
                        fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                      ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          print(
                              "Image path: ${image.path} -- MimeType: ${image.mimeType}");
                          setState(() {
                            _image = image.path;
                          });
                          API.updateProfileImage(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/upload.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: CircleBorder(),
                        fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                      ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          print("Image path: ${image.path}");
                          setState(() {
                            _image = image.path;
                          });
                          API.updateProfileImage(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/camera.png')),
                ],
              )
            ],
          );
        });
  }
}
