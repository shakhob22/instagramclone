import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagramclone/models/post_model.dart';
import 'package:instagramclone/models/user_model.dart';
import 'package:instagramclone/services/file_service.dart';
import 'package:instagramclone/services/http_service.dart';
import 'package:instagramclone/services/prefs_service.dart';
import 'package:instagramclone/services/utils_service.dart';

class DataService{

  static String folderPosts = "posts";
  static String folderFeeds = "feeds";
  static String folderFollowing = "following";
  static String folderFollowers = "followers";
  static String folderLikes = "likes";

  // User Related
  static Future storeUser(User user) async {
    user.uid = (await Prefs.loadUserId())!;
    Map<String, String> params = await Utils.deviceParams();
    user.deviceID = params["deviceID"];
    user.deviceType = params["deviceType"];
    user.deviceToken = params["deviceToken"];
    return FirebaseFirestore.instance.collection("users").doc(user.uid).set(user.toJson());
  }
  static Future loadUser() async {
    String? uid = await Prefs.loadUserId();
    var value = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    User user = User.fromJson(value.data()!);

    var querySnapshot1 = await FirebaseFirestore.instance.collection("users").doc(uid).collection("followers").get();
    var querySnapshot2 = await FirebaseFirestore.instance.collection("users").doc(uid).collection("following").get();

    user.followersCount = querySnapshot1.docs.length;
    user.followingCount = querySnapshot2.docs.length;

    return user;
  }

  static Future loadUserProfile(String uid) async {
    var value = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    User user = User.fromJson(value.data()!);

    var querySnapshot1 = await FirebaseFirestore.instance.collection("users").doc(uid).collection("followers").get();
    var querySnapshot2 = await FirebaseFirestore.instance.collection("users").doc(uid).collection("following").get();

    user.followersCount = querySnapshot1.docs.length;
    user.followingCount = querySnapshot2.docs.length;

    return user;
  }

  static Future updateUser(User user) async {
    String? uid = await Prefs.loadUserId();
    return FirebaseFirestore.instance.collection("users").doc(uid).update(user.toJson());
  }
  static Future<List<User>> searchUsers(String keyword) async {
    List<User> users = [];
    String? uid = await Prefs.loadUserId();
    var querySnapshot = await FirebaseFirestore.instance.collection("users").orderBy("email").startAt([keyword]).get();
    for (var result in querySnapshot.docs) {
      User newUser = User.fromJson(result.data());
      if(newUser.uid != uid){
        users.add(newUser);
      }
    }

    List<User> following = [];

    var querySnapshot2 = await FirebaseFirestore.instance.collection("users").doc(uid).collection("following").get();
    for (var result in querySnapshot2.docs) {
      var querySnapshot2 = await FirebaseFirestore.instance.collection("users").doc(result.id).get();
      following.add(User.fromJson(querySnapshot2.data()!));
    }

    for(User user in users){
      if(following.contains(user)){
        user.followed = true;
      }else{
        user.followed = false;
      }
    }

    return users;
  }

  // Follower and Following Related
  static Future<User> followUser(User someone) async {
    User me = await loadUser();

    // I followed to someone
    FirebaseFirestore.instance.collection("users").doc(me.uid).collection(folderFollowing).doc(someone.uid).set({}).then((value) => {
      Network.sentNotification(me.fullname!, someone)
    });

    // I am in someone`s followers
    FirebaseFirestore.instance.collection("users").doc(someone.uid).collection(folderFollowers).doc(me.uid).set({});

    return someone;
  }
  static Future<User> unfollowUser(User someone) async {
    User me = await loadUser();

    // I un followed to someone
    await FirebaseFirestore.instance.collection("users").doc(me.uid).collection(folderFollowing).doc(someone.uid).delete();

    // I am not in someone`s followers
    await FirebaseFirestore.instance.collection("users").doc(someone.uid).collection(folderFollowers).doc(me.uid).delete();

    return someone;
  }

  // Post Related
  static Future<Post> storePost(Post post) async {
    User me = await loadUser();
    post.uid = me.uid;
    post.date = Utils.currentDate();

    String postId = FirebaseFirestore.instance.collection("users").doc(me.uid).collection(folderPosts).doc().id;
    post.id = postId;

    await FirebaseFirestore.instance.collection("users").doc(me.uid).collection(folderPosts).doc(postId).set(post.toJson());
    return post;
  }
  static Future<List<Post>> loadPosts() async {
    List<Post> posts = [];
    String? uid = await Prefs.loadUserId();

    var querySnapshot = await FirebaseFirestore.instance.collection("users").doc(uid).collection("posts").get();

    for (var result in querySnapshot.docs) {
      Post post = Post.fromJson(result.data());
      post.mine = true;
      var q1 = await FirebaseFirestore.instance.collection("users").doc(uid).get();
      post.fullname = q1.data()!['fullname'];
      post.imgUser = q1.data()!['imgURL'];
      post.liked = await isLiked(post.uid, post.id);
      posts.add(post);
    }
    return posts;
  }

  static Future<List<Post>> loadUserPosts(String uid) async {
    List<Post> posts = [];

    var querySnapshot = await FirebaseFirestore.instance.collection("users").doc(uid).collection("posts").get();

    for (var result in querySnapshot.docs) {
      Post post = Post.fromJson(result.data());
      post.mine = true;
      var q1 = await FirebaseFirestore.instance.collection("users").doc(uid).get();
      post.fullname = q1.data()!['fullname'];
      post.imgUser = q1.data()!['imgURL'];
      post.liked = await isLiked(post.uid, post.id);
      posts.add(post);
    }
    return posts;
  }

  static Future<List<Post>> loadFeeds() async {
    List<Post> posts = [];
    String? uid = await Prefs.loadUserId();

    var querySnapshot = await FirebaseFirestore.instance.collection("users").doc(uid).collection("following").get();

    for (var someone in querySnapshot.docs) {
      var querySnapshot1 = await FirebaseFirestore.instance.collection("users").doc(someone.id).collection("posts").get();
      for (var result in querySnapshot1.docs) {
        Post post = Post.fromJson(result.data());
        if(someone.id == uid) post.mine = true;
        var q1 = await FirebaseFirestore.instance.collection("users").doc(someone.id).get();
        post.fullname = q1.data()!['fullname'];
        post.imgUser = q1.data()!['imgURL'];
        post.liked = await isLiked(post.uid, post.id);
        posts.add(post);
      }
    }
    return posts;
  }
  static Future<void> removePost(Post post) async{
    String? uid = await Prefs.loadUserId();
    await FileService.removePostImage(post.imgPost);
    await FirebaseFirestore.instance.collection("users").doc(uid)
        .collection("posts").doc(post.id).delete();

  }
  static Future<bool> isLiked(postUID, postID) async {
    String? uid = await Prefs.loadUserId();
    List likedPosts = [];
    var q1 = await FirebaseFirestore.instance.collection("users").doc(uid).collection("likes").get();
    for (var i in q1.docs) {
      likedPosts.add(i.id);
    }
    return likedPosts.contains(
        FirebaseFirestore.instance.collection("users").doc(uid).collection("likes").doc(postUID+"."+postID).id
    );
  }
  static Future<bool> likePost(postUID, postID) async {
    String? uid = await Prefs.loadUserId();
    bool liked = await isLiked(postUID, postID);

    if (!liked) {
      await FirebaseFirestore.instance.collection("users").doc(uid).collection("likes").doc(postUID!+"."+postID).set({});
      return true;
    } else {
      await FirebaseFirestore.instance.collection("users").doc(uid).collection("likes").doc(postUID!+"."+postID).delete();
      return false;
    }
  }
  static Future<List<Post>> loadLikes() async {
    String? uid = await Prefs.loadUserId();
    List<Post> posts = [];
    String postUID = "";
    String postID = "";

    var querySnapshot1 = await FirebaseFirestore.instance.collection("users").doc(uid).collection("likes").get();
    for (var i in querySnapshot1.docs) {
      List list = i.id.split(".");
      postUID = list[0];
      postID = list[1];

      var querySnapshot2 = await FirebaseFirestore.instance.collection("users").doc(postUID).collection("posts").doc(postID).get();
      if (querySnapshot2.data() != null) {
        Post post = Post.fromJson(querySnapshot2.data()!);
        if (post.uid == uid) post.mine = true;
        var q1 = await FirebaseFirestore.instance.collection("users").doc(post.uid).get();
        post.fullname = q1.data()!['fullname'];
        post.imgUser = q1.data()!['imgURL'];
        posts.add(post);
      } else {
        await FirebaseFirestore.instance.collection("users").doc(uid).collection("likes").doc(postUID+"."+postID).delete();
      }
    }
    return posts;
  }





}