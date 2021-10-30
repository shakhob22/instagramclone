import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagramclone/models/user_model.dart';
import 'package:instagramclone/pages/user_profile.dart';
import 'package:instagramclone/services/data_service.dart';
import 'package:instagramclone/services/utils_service.dart';

class MySearchPage extends StatefulWidget {
  const MySearchPage({Key? key}) : super(key: key);

  @override
  _MySearchPageState createState() => _MySearchPageState();
}

class _MySearchPageState extends State<MySearchPage> {

  var searchController = TextEditingController();
  List<User> items = [];
  bool isLoading = false;

  void _apiSearchUsers(String keyword) {
    setState(() {
      isLoading = true;
    });
    DataService.searchUsers(keyword).then((value) => {
      _respSearchUsers(value),
    });
  }
  void _respSearchUsers(List<User> users) {
    setState(() {
      items = users;
      isLoading = false;
    });
  }

  void _apiFollowUser(User user) async {
    setState(() {
      isLoading = true;
    });
    await DataService.followUser(user);
    setState(() {
      user.followed = true;
      isLoading = false;
    });
  }
  void _apiUnfollowUser(User user) async {
    setState(() {
      isLoading = true;
    });
    await DataService.unfollowUser(user);
    setState(() {
      user.followed = false;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _apiSearchUsers("");
    isLoading = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Search", style: TextStyle(color: Colors.black, fontFamily: "Billabong", fontSize: 32),),
      ),
      body: Stack(
        children: [
          Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (input){
                        _apiSearchUsers(input);
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        icon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _itemOfUser(items[index]);
                      },
                    ),
                  )
                ],
              )
          ),
          Utils.customLoader(isLoading, context)
        ],
      )
    );
  }

  Widget _itemOfUser(User user) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (BuildContext context) {
            return UserProfile(someuser: user);
          }
        ));
      },
      child: Container(
        height: 90,
        color: Colors.white,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(70),
                border: Border.all(
                  width: 1.5,
                  color: const Color.fromRGBO(193, 53, 132, 1)
                )
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22.5),
                child: (user.imgURL!.isEmpty) ?
                const Image(
                  image: AssetImage("assets/images/ic_userImage.png"),
                  height: 45,
                  width: 45,
                  fit: BoxFit.cover,
                ):
                Image.network(
                  user.imgURL!,
                  height: 45,
                  width: 45,
                  fit: BoxFit.cover,
                )
              ),
            ),
            const SizedBox(width: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(user.fullname!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                SizedBox(
                  width: 150,
                  child: Text(user.email!, overflow: TextOverflow.fade, softWrap: false,),
                ),
              ],
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 100,
                    child: Stack(
                      children: [
                        user.followed ?
                        OutlinedButton(
                          onPressed: (){
                            _apiUnfollowUser(user);
                          },
                          child: const Text("Following"),
                        ) :
                        ElevatedButton(
                            onPressed: (){
                              _apiFollowUser(user);
                            },
                            child: const Text("  Follow  "),
                        )
                      ],
                    )
                  ),
                ],
              )
            )
          ]
        ),
      ),
    );
  }
}
























