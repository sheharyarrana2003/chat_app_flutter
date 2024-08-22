import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isAnimate = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        isAnimate = true;
      });
    });
  }

  _handleGoogleClick() {
    Dialogs.showProgressBar(context);
    signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        print('\nUser: ${user.user}');
        print('\nUserAdditionalInfo: ${user.additionalUserInfo}');
        if ((await API.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomePage()));
        } else {
          await API.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomePage()));
          });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await API.auth.signInWithCredential(credential);
    } catch (e) {
      print('\nSignInWithGoogle: $e');
      Dialogs.showSnackBar(context, "Something went wrong ");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Welcome to We Chat "),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(seconds: 1),
            top: mq.height * 0.15,
            right: isAnimate ? mq.width * 0.25 : -mq.width * 0.5,
            width: mq.width * 0.5,
            child: Image.asset("images/chat.png"),
          ),
          Positioned(
            bottom: mq.height * 0.15,
            left: mq.width * 0.05,
            width: mq.width * 0.9,
            height: mq.height * 0.06,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                  shape: StadiumBorder(),
                  elevation: 1),
              onPressed: () {
                _handleGoogleClick();
              },
              icon: Image.asset(
                "images/google.png",
                height: mq.height * 0.05,
              ),
              label: RichText(
                text: TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    children: [
                      TextSpan(text: "Sign In with "),
                      TextSpan(
                        text: "Google",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )
                    ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
