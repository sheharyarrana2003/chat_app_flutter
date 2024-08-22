import 'package:chat_app/api/apis.dart';
import 'package:chat_app/auth/login_page.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarColor: Colors.white,
      ));
      if (API.auth.currentUser != null) {
        print("\nUser: ${API.auth.currentUser}");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomePage()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: mq.height * 0.15,
            right: mq.width * 0.25,
            width: mq.width * 0.5,
            child: Image.asset("images/chat.png"),
          ),
          Positioned(
              bottom: mq.height * 0.15,
              width: mq.width,
              child: Text(
                "The World is in your hand 🌍",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18, color: Colors.black, letterSpacing: 1.5),
              )),
        ],
      ),
    );
  }
}
