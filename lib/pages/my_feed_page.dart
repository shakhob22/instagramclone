import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagramclone/models/post_model.dart';
import 'package:instagramclone/models/user_model.dart';
import 'package:instagramclone/pages/user_profile_page.dart';
import 'package:instagramclone/services/data_service.dart';
import 'package:instagramclone/services/prefs_service.dart';
import 'package:instagramclone/services/utils_service.dart';
import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';

class MyFeedPage extends StatefulWidget {
  final PageController? pageController;
  const MyFeedPage({Key? key, this.pageController}) : super(key: key);

  @override
  _MyFeedPageState createState() => _MyFeedPageState();
}
class _MyFeedPageState extends State<MyFeedPage> {

  List<Post> item = [];
  bool isLoading = false;

  Future <void> _apiLoadFeeds() async {
    setState(() {isLoading = true;});
    List<Post> list = await DataService.loadFeeds();
    list.addAll(await DataService.loadPosts());
    setState(() {
      item = list;
      isLoading = false;
    });
  }
  void _apiPostLike(Post post) async {
    setState(() {isLoading = true;});
    post.liked = await DataService.likePost(post.uid, post.id);
    setState(() {isLoading = false;});
  }
  void _apiRemovePost(Post post) async {
    if (await Utils.commonDialog(context, "Remove post", "Do you want to remove a post?", "Confirm", "Cancel", false)) {
      setState(() {isLoading = true;});
      await DataService.removePost(post);
      _apiLoadFeeds();
    }
  }

  @override
  void initState() {
    super.initState();
    _apiLoadFeeds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text("Instagram", style: TextStyle(fontFamily: "Billabong", fontSize: 32, color: Colors.black),),
        actions: [
          IconButton(
            onPressed: (){
              widget.pageController!.animateToPage(2, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
            },
            icon: const Icon(Icons.camera_alt, color: Color.fromRGBO(252, 175, 69, 1),),
          )
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _apiLoadFeeds,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: item.length,
              itemBuilder: (ctx, index) {
                return _itemOfPost(item[index]);
              },
            ),
          ),
          Utils.customLoader(isLoading, context),
        ],
      ),
    );
  }

  Widget _itemOfPost(Post post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    User user = await DataService.loadUserProfile(post.uid!);
                    setState(() {
                      user.followed = true;
                    });
                    String? uid = await Prefs.loadUserId();
                    if (post.uid != uid) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (BuildContext context) {
                          return UserProfilePage(someuser: user);
                        }
                    ));
                    }
                  },
                  child: Row(
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
                            borderRadius: BorderRadius.circular(40),
                            child: post.imgUser!.isEmpty ?
                            const Image(
                              image: AssetImage("assets/images/ic_userImage.png"),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ) :
                            Image.network(
                              post.imgUser!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width-130,
                            child: Text(post.fullname!, overflow: TextOverflow.fade, softWrap: false, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width-130,
                            child: Text(post.date!, overflow: TextOverflow.fade, softWrap: false, style: const TextStyle(fontSize: 14),)
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                post.mine ?
                _moreButton(post) :
                const SizedBox.shrink()
              ],
            ),
          ),
          GestureDetector(
            onDoubleTap: (){
              _apiPostLike(post);
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
          Row(
            children: [
              IconButton(
                  onPressed: (){
                    _apiPostLike(post);
                  },
                  icon: post.liked ?
                  const Icon(CupertinoIcons.heart_fill, size: 28, color: Colors.red,) :
                  const Icon(CupertinoIcons.heart, size: 28,)
              ),
              IconButton(
                onPressed: () async {
                  setState(() {isLoading = true;});
                  Utils.onShare(context, post).then((value) => {
                    setState(() {isLoading = false;})
                  });
                },
                icon: const Icon(Icons.share),
              ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.visible,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: " ${post.caption}",
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5,)
        ],
      ),
    );
  }
  Widget _moreButton(Post post) {
    return PopupMenuButton<int>(
        icon: const Icon(Icons.more_horiz),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))
        ),
      itemBuilder: (context) => [
        PopupMenuItem(
            value: 0,
            child: Row(
              children: const [
                Icon(Icons.add),
                SizedBox(width: 5,),
                Text("Add new post", style: TextStyle(color: Colors.green),)
              ],
            )
        ),
        PopupMenuItem(
            value: 1,
            child: Row(
              children: const [
                Icon(Icons.share),
                SizedBox(width: 5,),
                Text("Share post",)
              ],
            )
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
            value: 2,
            child: Row(
              children: const [
                Icon(Icons.delete),
                SizedBox(width: 5,),
                Text("Delete post", style: TextStyle(color: Colors.red),)
              ],
            )
        ),
      ],
      onSelected: (index) {
          switch(index) {
            case 0 : {
              widget.pageController!.animateToPage(2, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
            } break;
            case 1: {
              setState(() {isLoading = true;});
              Utils.onShare(context, post).then((value) => {
                setState(() {isLoading = false;})
              });
            } break;
            case 2: {
              _apiRemovePost(post);
            }
          }
      },
    );
  }

}
