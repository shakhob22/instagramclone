import 'package:flutter/material.dart';
import 'package:instagramclone/models/user_model.dart';
import 'package:instagramclone/pages/signin_page.dart';
import 'package:instagramclone/services/auth_service.dart';
import 'package:instagramclone/services/data_service.dart';
import 'package:instagramclone/services/prefs_service.dart';
import 'package:instagramclone/services/utils_service.dart';

import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  static const String id = "signup_page";
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  bool showPassword = false;
  TextEditingController fullnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cpasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> _doSignUp() async {

    String name = fullnameController.text.toString().trim();
    String email = emailController.text.toString().trim();
    String password = passwordController.text.toString().trim();
    String cpassword = cpasswordController.text.toString().trim();

    if (password != cpassword) {
      Utils.fireToast("Invalid Password");
      return;
    }

    if (!Utils.checkEmail(email)) {
      Utils.fireToast("Invalid email address");
      return;
    }
    if (!Utils.checkPassword(password)) {
      Utils.fireToast("Invalid Password\n"
          "Minimum 1 uppercase or lowercase\n"
          "Minimum 1 Numeric Number\n");
      return;
    }
    setState(() {
      isLoading = true;
    });

    User user = User(fullname: name, email: email, password: password);

    await AuthService.signUpUser(name, email, password).then((value) async => {
      if (value != null) {
        await Prefs.saveUserId(value.uid),
        await DataService.storeUser(user),
        await Navigator.pushReplacementNamed(context, HomePage.id),
      },
      setState(() {
        isLoading = false;
      }),
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding:  const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(252, 175, 69, 1),
                        Color.fromRGBO(245, 96, 64, 1)
                      ]
                  )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Instagram",
                          style: TextStyle(color: Colors.white, fontSize: 45, fontFamily: 'Billabong'),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          height: 50,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(248, 151, 99, 1),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: TextField(
                            controller: fullnameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Fullname",
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          height: 50,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(248, 151, 99, 1),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: TextField(
                            controller: emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Email",
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          height: 50,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(248, 151, 99, 1),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: TextField(
                            controller: passwordController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  onPressed: (){
                                    setState(() {
                                      showPassword = !showPassword;
                                    });
                                  },
                                  icon:
                                  showPassword?
                                  const Icon(Icons.visibility_off, color: Colors.deepOrange):
                                  const Icon(Icons.visibility, color: Colors.deepOrange)
                              ),
                              hintText: "Password",
                              hintStyle: const TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                            ),
                            obscureText: !showPassword,
                            obscuringCharacter: "*",
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          height: 50,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(248, 151, 99, 1),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: TextField(
                            controller: cpasswordController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Confirm Password",
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                            ),
                            obscureText: !showPassword,
                            obscuringCharacter: "*",
                          ),
                        ),
                        const SizedBox(height: 10,),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24, width: 2),
                            ),
                            onPressed: (){
                              _doSignUp();
                            },
                            child: const Text("Sign Up", style: TextStyle(color: Colors.white70, fontSize: 16),),
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: const Text(
                            "Already have an account",
                            overflow: TextOverflow.clip,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: (){
                              Navigator.pushReplacementNamed(context, SignInPage.id);
                            },
                            child: const Text(
                                "Sign In",
                                overflow: TextOverflow.fade, softWrap: true,
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10,)
                ],
              ),
            ),
          ),
          Utils.customLoader(isLoading, context)
        ],
      )
    );
  }
}