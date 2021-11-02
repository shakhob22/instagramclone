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
        imgPost = json['imgPost'],
        id = json['id'],
        caption = json['caption'],
        date = json['date'];

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'id': id,
    'imgPost': imgPost,
    'caption': caption,
    'date': date
  };
}