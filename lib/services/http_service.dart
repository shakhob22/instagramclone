import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:instagramclone/models/user_model.dart';

class Network{

  static String BASE = "fcm.googleapis.com";
  static String api = "/fcm/send";
  static Map<String,String> headers = {
    "Authorization":"key=AAAAFCfBius:APA91bEruoRMombEAxJUseg5jjN6A8GBKYDBJj_eoNq04MH2Y6aEonG344SgQ46JR-dvB9v8PuAN8UN_O9yzDUsw-D4bIbjQ3CvahoaCHJv2iBU2gIg0W-ot_CvHkbwTsYi6Cai9GYCK",
    "Content-Type":"application/json; charset=UTF-8"
  };


  static Future sentNotification(String name, User someone) async {
    Map<String, dynamic> params =
    {
      "notification":
      {
        "body": name + " is your new subscriber",
        "title": "😎 New Followers 😎"
      },
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done"
      },
      "to": someone.deviceToken
    };

    print("PPPPPPPPPPPOST: ${await POST(params)}");

  }

  static Future<String?> POST(Map<String, dynamic> params) async {
    var uri = Uri.https(BASE, api); // http or https
    var response = await http.post(uri, headers: headers, body: jsonEncode(params));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    }
    print("status: " + response.statusCode.toString());
    return null;
  }

}