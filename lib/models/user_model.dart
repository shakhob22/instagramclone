class User {
  String uid = "";
  final String? fullname;
  final String? email;
  final String? password;
  String? imgURL;

  String? deviceID;
  String? deviceType;
  String? deviceToken;

  bool followed = false;

  int followersCount = 0;
  int followingCount = 0;

  User({this.fullname, this.email, this.password});

  User.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        fullname = json['fullname'],
        email = json['email'],
        password = json['password'],
        imgURL = json['imgURL'] ?? "",
        deviceID = json['deviceID'],
        deviceType = json['deviceType'],
        deviceToken = json['deviceToken'];

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'fullname': fullname,
    'email': email,
    'password': password,
    'imgURL': imgURL,
    'deviceID': deviceID,
    'deviceType': deviceType,
    'deviceToken': deviceToken,
  };

  @override
  bool operator ==(other) {
    return (other is User) && other.uid == uid;
  }
}