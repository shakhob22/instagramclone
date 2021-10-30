import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagramclone/models/post_model.dart';
import 'package:instagramclone/models/user_model.dart';
import 'package:instagramclone/pages/home_page.dart';
import 'package:instagramclone/services/auth_service.dart';
import 'package:instagramclone/services/data_service.dart';
import 'package:instagramclone/services/file_service.dart';
import 'package:instagramclone/services/utils_service.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {

  int count = 2;
  File? image;
  String fullName = "", email = "", imgURL = "";
  int countPosts = 0, countFollowers = 0, countFollowing = 0;
  List<Post> items = [];
  bool isLoading = false;

  void _apiLoadUser() async {
    User user = await DataService.loadUser();
    setState(() {
      fullName = user.fullname!;
      email = user.email!;
      imgURL = user.imgURL!;
      countFollowers =  user.followersCount;
      countFollowing = user.followingCount;
      isLoading = false;
    });
  }
  void _apiChangePhoto() async {
    setState(() {
      isLoading = true;
    });
    FileService.uploadUserImage(image!).then((value) => {
      _apiUpdateUser(value),
    });
  }
  void _apiUpdateUser(String downloadUrl) async {
    User user = await DataService.loadUser();
    user.imgURL = downloadUrl;
    HomePage.imgURL = downloadUrl;
    await DataService.updateUser(user);
    _apiLoadUser();
  }
  void _apiLoadPosts() async {
    setState(() {
      isLoading = true;
    });
    items = await DataService.loadPosts();
    setState(() {
      countPosts = items.length;
      isLoading = false;
    });
  }
  void _apiRemovePost(Post post) async {
    if (await Utils.commonDialog(context, "Remove post", "Do you want to remove a post?", "Confirm", "Cancel", false)) {
      setState(() {isLoading = true;});
      await DataService.removePost(post);
      _apiLoadPosts();
    }
  }

  @override
  void initState() {
    super.initState();
    _apiLoadUser();
    _apiLoadPosts();
    isLoading = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Colors.black, fontFamily: "Billabong", fontSize: 32),),
        actions: [
          IconButton(
            onPressed: () async {
              if (await Utils.commonDialog(context, "Log out", "Are you sure want to log out?", "Confirm", "Cancel", false)) {
                AuthService.signOutUser(context);
              }
            },
            icon: const Icon(Icons.exit_to_app, color: Colors.red,),
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // #myFoto
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
                          child: imgURL == "" ?
                          const Image(
                            height: 70,
                            width: 70,
                            image: AssetImage("assets/images/ic_userImage.png"),
                            fit: BoxFit.cover,
                          ) :
                          Image.network(
                            imgURL,
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          )
                      ),
                    ),
                    SizedBox(
                      height: 92,
                      width: 92,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: (){
                              _bottomsheet(context);
                            } ,
                            icon: const Icon(Icons.add_circle, color: Colors.purple,),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                const SizedBox(height: 3,),
                Text(email, style: TextStyle(color: Colors.grey.shade700),),
                // #myInfos
                SizedBox(
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(countPosts.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                            const Text("POSTS", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.grey),)
                          ],
                        ),
                      ),
                      const VerticalDivider(
                        color: Colors.grey,
                        indent: 25,
                        endIndent: 25,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(countFollowers.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                            const Text("FOLLOWERS", overflow: TextOverflow.fade, softWrap: false, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.grey),)
                          ],
                        ),
                      ),
                      const VerticalDivider(
                        color: Colors.grey,
                        indent: 25,
                        endIndent: 25,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(countFollowing.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                            const Text("Following", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.grey),)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                // #CountButton
                Row(
                  children: [
                    Expanded(
                      child: IconButton(
                        onPressed: (){
                          setState(() {
                            count = 1;
                          });
                        },
                        icon: Icon(
                            Icons.list_alt,
                            color: (count == 1) ? Colors.blue:Colors.black
                        ),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: (){
                          setState(() {
                            count = 2;
                          });
                        },
                        icon: Icon(
                            Icons.grid_view,
                            color: (count == 2) ? Colors.blue:Colors.black
                        ),
                      ),
                    )
                  ],
                ),
                // #myPosts
                Expanded(
                  child: GridView.builder(
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: count),
                      itemBuilder: (ctx, index){
                        return _itemOfPost(items[index]);
                      }
                  ),
                )
              ],
            ),
          ),
          Utils.customLoader(isLoading, context)
        ],
      )

    );
  }

  Widget _itemOfPost(Post post) {
    return Container(
        margin: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onLongPress: () {
                _apiRemovePost(post);
              },
              child: CachedNetworkImage(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                imageUrl: post.imgPost.toString(),
                placeholder: (context, url) => const Center(child: CircularProgressIndicator(),),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            post.caption!,
            style: TextStyle(color: Colors.black87.withOpacity(0.7)),
            maxLines: 2,
          ),
        ],
      )
    );
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
  Future<void> takePhoto() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;
    final imageTemporary = File(image.path);
    setState(() {
      this.image = imageTemporary;
    });
    _apiChangePhoto();
  }
  void _bottomsheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (context){
        return SizedBox(
            height: 150,
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
                )
              ],
            )
        );
      },
    );
  }

}




















