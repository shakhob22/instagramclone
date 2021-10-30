import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagramclone/pages/signup_page.dart';
import 'package:instagramclone/services/auth_service.dart';
import 'package:instagramclone/services/prefs_service.dart';
import 'package:instagramclone/services/utils_service.dart';
import 'home_page.dart';

class SignInPage extends StatefulWidget {
  static const String id = "signin_page";
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  bool showPassword = false;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  bool isLoading = false;

  void _doSignIn(){
    String email = emailController.text.toString().trim();
    String password = passwordController.text.toString().trim();
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    bool passwordValid = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(password);

    if (email.isEmpty || password.isEmpty){
      Utils.fireToast("Invalid email address or password");
      return;
    }
    if (!emailValid) {
      Utils.fireToast("Invalid email address");
      return;
    }
    if (!passwordValid) {
      Utils.fireToast("Invalid Password\n"
          "Minimum 1 Upper case\n"
          "Minimum 1 lowercase\n"
          "Minimum 1 Numeric Number\n"
          "Minimum 1 Special Character\n"
          "Common Allow Character ( ! @ # \$ & * ~ )");
      return;
    }

    setState(() {
      isLoading = true;
    });

    AuthService.signInUser(email, password).then((value) async => {
      isLoading = false,
      await Prefs.saveUserId(value!.uid),
      Navigator.pushReplacementNamed(context, HomePage.id)
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
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24, width: 2),
                            ),
                            onPressed: (){
                              _doSignIn();
                            },
                            child: const Text("Sign In", style: TextStyle(color: Colors.white70, fontSize: 16),),
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.pushReplacementNamed(context, SignUpPage.id);
                        },
                        child: const Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
