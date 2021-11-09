import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagramclone/models/post_model.dart';
import 'package:instagramclone/services/data_service.dart';
import 'package:instagramclone/services/file_service.dart';

class MyUploadPage extends StatefulWidget {
  final PageController? pageController;
  const MyUploadPage({Key? key, this.pageController}) : super(key: key);

  @override
  _MyUploadPageState createState() => _MyUploadPageState();
}
class _MyUploadPageState extends State<MyUploadPage> {

  var captionController = TextEditingController();
  File? image;
  bool isLoading = false;

  void _uploadNewPost() {
    String caption = captionController.text.toString().trim();
    if (caption.isEmpty) return;
    if (image == null) return;
    _apiPostImage();
  }

  void _apiPostImage() {
    setState(() {
      isLoading = true;
    });
    FileService.uploadPostImage(image!).then((value) => {
      _resPostImage(value),
      print("POST IMAGE: ${value}")
    });
  }

  void _resPostImage(String downloadUrl) {
    String caption = captionController.text.toString().trim();
    Post post = Post(caption: caption, imgPost: downloadUrl);
    _apiStorePost(post);
  }

  void _apiStorePost(Post post) async {
    setState(() {isLoading = false;});
    await DataService.storePost(post);
    captionController.text = "";
    image = null;
    widget.pageController!.animateToPage(0, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Upload", style: TextStyle(fontFamily: "Billabong", fontSize: 32, color: Colors.black),),
        actions: [
          IconButton(
            onPressed: (){
              _uploadNewPost();
              //widget.pageController!.animateToPage(0, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
            },
            icon: const Icon(Icons.drive_folder_upload, color: Colors.blue,),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: (){
                      _bottomsheet(context);
                    },
                    child: Container(
                        height: MediaQuery.of(context).size.width,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child:
                        image == null?
                        const Icon(Icons.add_a_photo, size: 60, color: Colors.grey,):
                        Stack(
                          children: [
                            Image.file(
                              image!,
                              height: MediaQuery.of(context).size.width,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Container(
                                height: double.infinity,
                                width: double.infinity,
                                color: Colors.black12,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      alignment: Alignment.topRight,
                                      onPressed: (){
                                        setState(() {
                                          image = null;
                                        });
                                      },
                                      icon: const Icon(Icons.highlight_remove_outlined, color: Colors.white,),
                                    ),
                                  ],
                                )
                            )
                          ],
                        )
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: TextField(
                      controller: captionController,
                      style: const TextStyle(color: Colors.black),
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: "Caption",
                        hintStyle: TextStyle(fontSize: 17.0, color: Colors.black38),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          isLoading ?
          Container(
            color: Colors.white.withOpacity(0.1),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: const Center(child: CircularProgressIndicator())
          ):
          const SizedBox.shrink()
        ],
      )
    );
  }

  Future pickPhoto() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final imageTemporary = File(image.path);
    setState(() {
      this.image = imageTemporary;
    });
  }
  Future takePhoto() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;
    final imageTemporary = File(image.path);
    setState(() {
      this.image = imageTemporary;
    });
  }
  void _bottomsheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (context){
        return SizedBox(
          height: 140,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListTile(
                //tileColor: Colors.red,
                leading: const Icon(Icons.photo_library),
                title: const Text("Pick photo"),
                onTap: () {
                  pickPhoto();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                //tileColor: Colors.green,
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take photo'),
                onTap: () {
                  takePhoto();
                  Navigator.pop(context);
                },
              )
            ],
          )
        );
      },
    );
  }

}
