import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagramclone/services/prefs_service.dart';

class FileService {
  static final _storage = FirebaseStorage.instance.ref();
  static const folderPost = "postImages";
  static const folderUser = "userImages";

  static Future<String> uploadUserImage(File _image) async {
    String? uid = await Prefs.loadUserId();
    String imgName = uid!;
    TaskSnapshot taskSnapshot =
    await _storage.child(folderUser).child(imgName).putFile(_image);
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  static Future<String> uploadPostImage(File _image) async {
    String? uid = await Prefs.loadUserId();
    String imgName = uid! +"_" + DateTime.now().toString();
    TaskSnapshot taskSnapshot =
    await _storage.child(folderPost).child(imgName).putFile(_image);
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  static Future<void> removePostImage(imageURL) async {
    await FirebaseStorage.instance.refFromURL(imageURL).delete();
  }

}