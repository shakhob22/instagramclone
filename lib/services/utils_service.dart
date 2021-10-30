import 'dart:io';
import 'dart:math';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagramclone/models/post_model.dart';
import 'package:instagramclone/services/prefs_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart';
import 'package:share_plus/share_plus.dart';

class Utils {

  static void fireToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static String currentDate() {
    DateTime now = DateTime.now();

    String convertedDateTime =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString()}:${now.minute.toString()}";
    return convertedDateTime;
  }

  static Widget customLoader(bool isLoading,context) {
    return
      isLoading ?
      SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Container(
          color: Colors.white.withOpacity(.1),
          child: Center(
            child: SizedBox(
              height: 100,
              width: 100,
              child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  color: Colors.white,
                  child: Container(
                      padding: const EdgeInsets.all(20),
                      child: const CircularProgressIndicator()
                  )
              ),
            ),),
        ),
      ) :
      const SizedBox.shrink();
  }

  static Future<bool> commonDialog(context, title, content, yes, no, isSingle) async {
    return await showDialog (
        context: context,
        builder: (BuildContext context) {
          return Platform.isAndroid ?
          AlertDialog(
            title: Text(title, style: const TextStyle(fontSize: 18),),
            content: Text(content, style: const TextStyle(fontSize: 16),),
            actions: [
              !isSingle ?
              TextButton(
                onPressed: (){
                  Navigator.pop(context, false);
                },
                child: Text(no),
              ) :
              const SizedBox.shrink(),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(yes, style: const TextStyle(color: Colors.red),),
              )
            ],
          ) :
          CupertinoAlertDialog(
            title: Text(title, style: const TextStyle(fontSize: 18),),
            content: Text(content, style: const TextStyle(fontSize: 16),),
            actions: [
              !isSingle ?
              TextButton(
                onPressed: (){
                  Navigator.of(context).pop(false);
                },
                child: Text(no),
              ) :
              const SizedBox.shrink(),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                },
                child: Text(yes, style: const TextStyle(color: Colors.red),),
              )
            ],
          );
        }
    );
  }

  static Future<Map<String, String>>  deviceParams() async{
    Map<String, String> params = {};
    var deviceInfo = DeviceInfoPlugin();
    String? fcmToken = await Prefs.loadFCM() ?? "";

    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      params.addAll({
        'deviceID': iosDeviceInfo.identifierForVendor,
        'deviceType': "I",
        'deviceToken': fcmToken,
      });
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      params.addAll({
        'deviceID': androidDeviceInfo.androidId,
        'deviceType': "A",
        'deviceToken': fcmToken,
      });
    }
    return params;
  }

  static Future<void> showLocalNotification(Map<String, dynamic> message) async {
    String title = message['title'];
    String body = message['body'];

    var android = const AndroidNotificationDetails('channelId', 'channelName', channelDescription: 'channelDescription');
    var iOS = const IOSNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);

    int id = Random().nextInt(pow(2, 31).toInt() - 1);
    await FlutterLocalNotificationsPlugin().show(id, title, body, platform);

  }


  static void onShare(BuildContext context, Post post) async {
    String imageurl = post.imgPost!;
    final uri = Uri.parse(imageurl);
    final response = await get(uri);
    final bytes = response.bodyBytes;
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/image.jpg';
    File(path).writeAsBytesSync(bytes);
    Share.shareFiles(
      [path],
      text: "from " + post.fullname!+":\n"+
      post.caption!,
    );

  }


}

















