import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagramclone/models/post_model.dart';
import 'package:instagramclone/services/data_service.dart';
import 'package:instagramclone/services/utils_service.dart';

class MyLikesPage extends StatefulWidget {
  const MyLikesPage({Key? key}) : super(key: key);

  @override
  _MyLikesPageState createState() => _MyLikesPageState();
}

class _MyLikesPageState extends State<MyLikesPage> {
  List<Post> items = [];
  bool isLoading = false;

  void _apiLoadLikes() {
    setState(() {isLoading = true;});
    DataService.loadLikes().then((value) => {
      _resLoadLikes(value)
    });
  }
  void _resLoadLikes(List<Post> posts) {
    setState(() {
      items = posts;
      isLoading = false;
    });
  }

  void _apiPostUnlike(Post post) async {
    setState(() {isLoading = true;});
    post.liked = await DataService.likePost(post.uid, post.id);
    _apiLoadLikes();
    setState(() {isLoading = false;});
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    _apiLoadLikes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          title: const Text("Likes", style: TextStyle(fontFamily: "Billabong", fontSize: 32, color: Colors.black),),
        ),
        body: Stack(
          children: [
            items.isNotEmpty ?
            ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, index) {
                return _itemOfPost(items[index]);
              },
            ) :
            const Center(
              child: Text("No liked posts"),
            ),
            Utils.customLoader(isLoading, context)
          ],
        )
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
                IconButton(
                  onPressed: (){},
                  icon: post.mine ?
                  const Icon(Icons.more_horiz) :
                  const SizedBox.shrink()
                )
              ],
            ),
          ),
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            imageUrl: post.imgPost.toString(),
            placeholder: (context, url) => const Center(child: CircularProgressIndicator(),),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
          ),
          Row(
            children: [
              IconButton(
                onPressed: (){
                  _apiPostUnlike(post);
                  },
                icon: const Icon(CupertinoIcons.heart_fill, color: Colors.red, size: 28,),
              ),
              IconButton(
                onPressed: (){},
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
          const Divider(
            color: Colors.black,
          )
        ],
      ),
    );
  }
}
