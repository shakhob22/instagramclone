import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagramclone/models/user_model.dart';
import 'package:instagramclone/services/data_service.dart';
import 'package:instagramclone/services/utils_service.dart';
import 'my_feed_page.dart';
import 'my_likes_page.dart';
import 'my_profile_page.dart';
import 'my_search_page.dart';
import 'my_upload_page.dart';

class HomePage extends StatefulWidget {
  static const String id = "home_page";
  static String? imgURL = "";
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _currentTap = 0;
  PageController? _pageController;
  Map<String, String> message = {};

  _initNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Utils.showLocalNotification({
        'title': message.notification!.title,
        'body': message.notification!.body
      });
    });
  }

  void _apiImageURL() async {
    User user = await DataService.loadUser();
    setState(() {
      HomePage.imgURL = user.imgURL ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _apiImageURL();
    _initNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (int index){
          setState(() {
            _currentTap = index;
          });
        },
        children: [
          MyFeedPage(pageController: _pageController,),
          const MySearchPage(),
          MyUploadPage(pageController: _pageController,),
          const MyLikesPage(),
          const MyProfilePage()
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        onTap: (int index){
          setState(() {
            _currentTap = index;
            _pageController!.animateToPage(index,
                duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
          });
        },
        currentIndex: _currentTap,
        activeColor: const Color.fromRGBO(252, 175, 69, 1),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 32,
            ),
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 32,
            ),
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.add_box,
              size: 32,
            ),
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite,
              size: 32,
            ),
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(70),
                  border: Border.all(
                    width: 1.5,
                    color: const Color.fromRGBO(193, 53, 132, 1),
                  )
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: (HomePage.imgURL!.isEmpty) ?
                const Icon(
                  Icons.person,
                  size: 32,
                ) :
                Image.network(
                  HomePage.imgURL!,
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                )
              ),
            )
          )
        ],
      ),
    );
  }
}
