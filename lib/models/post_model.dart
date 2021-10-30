class Post {
  String? uid;
  String? fullname;
  String? imgUser;
  String? id;
  final String? imgPost;
  final String? caption;
  String? date;
  bool liked = false;

  bool mine = false;

  Post({this.imgPost, this.caption});

  Post.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        //fullname = json['fullname'],
        //imgUser = json['imgUser'],
        imgPost = json['imgPost'],
        id = json['id'],
        caption = json['caption'],
        date = json['date'];
        //liked = json['liked'];

  Map<String, dynamic> toJson() => {
    'uid': uid,
    //'fullname': fullname,
    //'imgUser': imgUser,
    'id': id,
    'imgPost': imgPost,
    'caption': caption,
    'date': date
    //'liked': liked,
  };
}