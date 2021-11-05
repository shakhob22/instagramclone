import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagramclone/models/post_model.dart';
import 'package:instagramclone/models/user_model.dart';
import 'package:instagramclone/services/data_service.dart';
import 'package:instagramclone/services/utils_service.dart';

class UserProfilePage extends StatefulWidget {
  static const String id = "user_profile";
  final dynamic someuser;
  const UserProfilePage({Key? key, this.someuser}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {

  int count = 2;
  File? image;
  String fullName = "", email = "", imgURL = "";
  int countPosts = 0, countFollowers = 0, countFollowing = 0;
  bool followed = false;
  List<Post> items = [];
  bool isLoading = false;

  void _apiLoadUser() async {
    setState(() {
      followed = widget.someuser.followed;
    });
    User user = await DataService.loadUserProfile(widget.someuser.uid);
    setState(() {
      fullName = user.fullname!;
      email = user.email!;
      imgURL = user.imgURL!;
      countFollowers = user.followersCount;
      countFollowing = user.followingCount;
      isLoading = false;
    });
  }
  void _apiLoadPosts() async {
    setState(() {
      isLoading = true;
    });
    items = await DataService.loadUserPosts(widget.someuser.uid);
    setState(() {
      countPosts = items.length;
      isLoading = false;
    });
  }

  void _apiFollowUser() async {
    setState(() {
      isLoading = true;
    });
    await DataService.followUser(widget.someuser);
    setState(() {
      widget.someuser.followed = true;
      followed = true;
      isLoading = false;
    });
  }
  void _apiUnfollowUser() async {
    setState(() {
      isLoading = true;
    });
    await DataService.unfollowUser(widget.someuser);
    setState(() {
      widget.someuser.followed = false;
      followed = false;
      isLoading = false;
    });
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
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text("Profile", style: TextStyle(color: Colors.black, fontFamily: "Billabong", fontSize: 32),),
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
                  const SizedBox(height: 10,),
                  Text(fullName, overflow: TextOverflow.ellipsis, softWrap: false, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                  const SizedBox(height: 3,),
                  //Text(email, style: TextStyle(color: Colors.grey.shade700),),
                  Stack(
                    children: [
                      followed ?
                      OutlinedButton(
                        onPressed: (){
                          _apiUnfollowUser();
                        },
                        child: const Text("Following", overflow: TextOverflow.ellipsis, softWrap: false,),
                      ) :
                      ElevatedButton(
                        onPressed: (){
                          _apiFollowUser();
                        },
                        child: const Text("  Follow  ", overflow: TextOverflow.ellipsis, softWrap: false,),
                      )
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
                              const Text("POSTS", overflow: TextOverflow.ellipsis, softWrap: false, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.grey),)
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
              child: CachedNetworkImage(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                imageUrl: post.imgPost.toString(),
                placeholder: (context, url) => const Center(child: CircularProgressIndicator(),),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
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
}
