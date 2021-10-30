import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagramclone/pages/signin_page.dart';
import 'package:instagramclone/services/prefs_service.dart';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  static const String id = "splash_page";

  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  void _initNotification() {
    FirebaseMessaging.instance.requestPermission(sound: true, badge: true, alert: true, );
    /*_firebaseMessaging.getNotificationSettings
    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });*/

    FirebaseMessaging.instance.getToken().then((String? token) {
      assert(token != null);
      print(token);
      Prefs.saveFCM(token!);
    });
  }

  @override
  void initState() {
    super.initState();
    _initNotification();

    Timer(const Duration(seconds: 1), () {
      FirebaseAuth.instance
          .authStateChanges()
          .listen((User? user) {
          if (user == null) {
            Navigator.pushReplacementNamed(context, SignInPage.id);
          } else {
            Navigator.pushReplacementNamed(context, HomePage.id);
          }
        });
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(252, 175, 69, 1),
                  Color.fromRGBO(245, 96, 64, 1)
                ]
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Expanded(
              child: Center(
                child: Text(
                  "Instagram",
                  style: TextStyle(color: Colors.white, fontSize: 45, fontFamily: 'Billabong'),
                ),
              ),
            ),
            Text(
              "from Facebook",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}
