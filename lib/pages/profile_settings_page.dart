import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagramclone/models/user_model.dart';
import 'package:instagramclone/services/data_service.dart';
import 'package:instagramclone/services/file_service.dart';
import 'package:instagramclone/services/prefs_service.dart';
import 'package:instagramclone/services/utils_service.dart';

import 'home_page.dart';

class ProfileSettingsPage extends StatefulWidget {
  static const String id = "profile_settings_page";
  final String? imgURL;
  final String? fullname;
  const ProfileSettingsPage({Key? key, this.imgURL, this.fullname}) : super(key: key);

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {

  var fullnameController = TextEditingController();
  File? image;
  bool isLoading = false;
  String fullname = "", imgURL = "";
  bool modified = false;

  @override
  void initState() {
    super.initState();
    fullname = widget.fullname.toString();
    imgURL = widget.imgURL.toString();
    fullnameController.value = TextEditingValue(text: fullname);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              Visibility(
                visible: modified,
                child: IconButton(
                  onPressed: (){
                    _apiUpdateUserName();
                  },
                  icon: const Icon(Icons.done, color: Colors.green,),
                ),
              )
            ],
          ),
          body: Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(70),
                              border: Border.all(
                                width: 1.5,
                                color: const Color.fromRGBO(193, 53, 132, 1),
                              )
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(35),
                              child: widget.imgURL == "" ?
                              const Image(
                                height: 70,
                                width: 70,
                                image: AssetImage("assets/images/ic_userImage.png"),
                                fit: BoxFit.cover,
                              ) :
                              Image.network(
                                widget.imgURL.toString(),
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              )
                          ),
                        ),
                        Container(
                          height: 80,
                          width: 80,
                          child: GestureDetector(
                            onTap: (){
                              _bottomsheet(context);
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(25)
                              ),
                              child: const Center(
                                child: Icon(Icons.add_a_photo, color: Color.fromRGBO(193, 53, 132, 1), size: 22,),
                              ),
                            ),
                          ),
                          alignment: Alignment.bottomRight,
                        )
                      ],
                    ),
                    const SizedBox(height: 20,),
                    TextField(
                      onChanged: (str) {
                        print("SSSSSSSSSSSSSSSS: " + str);
                        print("SSSSSSSSSSSSSSSS: " + fullname);
                        if (fullname != str) {
                          setState(() {
                            modified = true;
                          });
                        } else {
                          setState(() {
                            modified = false;
                          });
                        }
                      },
                      controller: fullnameController,
                      decoration: const InputDecoration(
                        alignLabelWithHint: true,
                        label: Text("User name", style: TextStyle(color: Color.fromRGBO(252, 175, 69, 1), fontSize: 18),),
                      ),
                    ),
                  ],
                ),
              )
          ),
        ),
        Utils.customLoader(isLoading, context)
      ],

    );
  }

  /*void _apiLoadUser() async {
    User user = await DataService.loadUser();
    setState(() {
      fullname = user.fullname!;
      imgURL = user.imgURL!;
      isLoading = false;
    });
  }*/
  void _apiChangePhoto() async {
    setState(() {isLoading = true;});
    FileService.uploadUserImage(image!).then((value) => {
      _apiUpdateUserImage(value),
    });
  }
  void _apiUpdateUserImage(String downloadUrl) async {
    //User user = await DataService.loadUser();
    //user.imgURL = downloadUrl;
    HomePage.imgURL = downloadUrl;
    setState(() {imgURL = downloadUrl;});
    String? uid = await Prefs.loadUserId();
    FirebaseFirestore.instance.collection("users").doc(uid).update({
      "imgURL": downloadUrl
    });
    setState(() {
      isLoading = false;
    });
  }

  void _apiUpdateUserName() async {
    String fullname = fullnameController.text.toString().trim();
    setState(() {
      isLoading = true;
      this.fullname = fullname;
    });
    String? uid = await Prefs.loadUserId();
    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "fullname": fullname
    });
    setState(() {
      isLoading = false;
    });
  }

  void pickPhoto() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final imageTemporary = File(image.path);
    setState(() {
      this.image = imageTemporary;
    });
    _apiChangePhoto();
  }
  void takePhoto() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;
    final imageTemporary = File(image.path);
    setState(() {
      this.image = imageTemporary;
    });
    _apiChangePhoto();
  }
  void _bottomsheet(context) {
    showModalBottomSheet(context: context, builder: (context) {
      return SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Pick photo"),
                onTap: () {
                  pickPhoto();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take photo'),
                onTap: () {
                  takePhoto();
                  Navigator.pop(context);
                },
              ),
              const Divider(
                indent: 15,
                endIndent: 15,
                color: Colors.black,
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red,),
                title: const Text("Delete", style: TextStyle(color: Colors.red),),
                onTap: () {
                  pickPhoto();
                  Navigator.pop(context);
                },
              ),
            ],
          )
      );
    });
  }

}
