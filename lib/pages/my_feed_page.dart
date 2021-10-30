import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagramclone/models/post_model.dart';
import 'package:instagramclone/services/data_service.dart';
import 'package:instagramclone/services/utils_service.dart';
import 'package:share_plus/share_plus.dart';

class MyFeedPage extends StatefulWidget {
  final PageController? pageController;
  const MyFeedPage({Key? key, this.pageController}) : super(key: key);

  @override
  _MyFeedPageState createState() => _MyFeedPageState();
}

class _MyFeedPageState extends State<MyFeedPage> {

  List<Post> item = [];
  bool isLoading = false;

  void _apiLoadFeeds() async {
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
          ListView.builder(
            itemCount: item.length,
            itemBuilder: (ctx, index) {
              return _itemOfPost(item[index]);
            },
          ),
          Utils.customLoader(isLoading, context)
        ],
      ),
    );
  }

  Widget _itemOfPost(Post post) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          borderRadius: BorderRadius.circular(40),
                          child: post.imgUser == null ?
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
                        Text(post.fullname!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                        Text(post.date!, style: const TextStyle(fontSize: 14),)
                      ],
                    )
                  ],
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
            child: CachedNetworkImage(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              imageUrl: post.imgPost.toString(),
              placeholder: (context, url) => const Center(child: CircularProgressIndicator(),),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.cover,
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
                  Utils.onShare(context, post);
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
          const Divider()
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
            onTap: () {
              widget.pageController!.animateToPage(2, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
            },
            value: 0,
            child: Row(
              children: const [
                Icon(Icons.add),
                SizedBox(width: 5,),
                Text("Add new post", style: TextStyle(color: Colors.green),)
              ],
            )
        ),
        //const PopupMenuDivider(),
        PopupMenuItem(
            value: 1,
            child: Row(
              children: const [
                Icon(Icons.delete),
                SizedBox(width: 5,),
                Text("Delete this post", style: TextStyle(color: Colors.red),)
              ],
            )
        ),
      ],
      onSelected: (index) {
          if (index == 1) {
            _apiRemovePost(post);
          }
      },
    );
  }

}






















