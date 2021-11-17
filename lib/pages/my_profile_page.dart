import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagramclone/models/post_model.dart';
import 'package:instagramclone/models/user_model.dart';
import 'package:instagramclone/pages/profile_settings_page.dart';
import 'package:instagramclone/services/auth_service.dart';
import 'package:instagramclone/services/data_service.dart';
import 'package:instagramclone/services/utils_service.dart';
import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';

class MyProfilePage extends StatefulWidget {
  final PageController? pageController;
  const MyProfilePage({Key? key, this.pageController}) : super(key: key);

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

  void _apiLoadPosts() async {
    setState(() {isLoading = true;});
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
                Map result = await Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context) {
                      return ProfileSettingsPage(fullname: fullName, imgURL: imgURL,);
                    }
                ));
                if (result.containsKey("fullname")){
                  setState(() {
                    fullName = result["fullname"];
                  });
                }
                if (result.containsKey("imgURL")){
                  setState(() {
                    imgURL = result["imgURL"];
                  });
                }
              },
              icon: const Icon(Icons.edit, color: Colors.red,),
            ),
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
                  Row(
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
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width-130,
                            child: Text(fullName, overflow: TextOverflow.fade, softWrap: false, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                          ),
                          const SizedBox(height: 3,),
                          Text(email, overflow: TextOverflow.ellipsis, softWrap: false, style: TextStyle(color: Colors.grey.shade700),),
                          const SizedBox(height: 15,),
                        ],
                      ),
                    ],
                  ),
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
                              const Text("POSTS", overflow: TextOverflow.fade, softWrap: false, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.grey),)
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
                              const Text("FOLLOWERS", overflow: TextOverflow.ellipsis, softWrap: false, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.grey),)
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
                              const Text("Following", overflow: TextOverflow.ellipsis, softWrap: false, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.grey),)
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
                _options(post);
              },
              child: PinchZoomImage(
                image: CachedNetworkImage(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                  imageUrl: post.imgPost.toString(),
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(),),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 3,
          ),
          Text(
            post.caption!,
            style: TextStyle(color: Colors.black87.withOpacity(0.7)),
          ),
        ],
      )
    );
  }

  void _options(Post post) {
    showDialog (
        context: context,
        builder: (BuildContext context) {
          if (Platform.isAndroid) {
            return AlertDialog(
              actions: [
                ListTile(
                  onTap: (){
                    Navigator.pop(context);
                    widget.pageController!.animateToPage(2, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
                  },
                  leading: const Icon(Icons.add),
                  title: const Text("Add new post"),
                ),
                ListTile(
                  onTap: (){
                    Navigator.pop(context);
                    setState(() {isLoading = true;});
                    Utils.onShare(context, post).then((value) => {
                      setState(() {isLoading = false;})
                    });
                  },
                  leading: const Icon(Icons.share),
                  title: const Text("Share post"),
                ),
                const Divider(color: Colors.grey,),
                ListTile(
                  onTap: (){
                    Navigator.pop(context);
                    _apiRemovePost(post);
                  },
                  leading: const Icon(Icons.delete, color: Colors.red,),
                  title: const Text("Delete post", style: TextStyle(color: Colors.red),),
                )
              ],
            );
          } else {
            return const CupertinoAlertDialog();
          }
        });
  }

}




















