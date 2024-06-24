import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/screens/home_screen/home_screen.dart';
import 'package:magic_sign_mobile/screens/login_screen/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class splashScreen extends StatefulWidget {
  static String routeName = 'SplashScreen';

  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  var isLoggedIn = false;
  isLoggedInFn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.getString("access_token") != null;
    setState(() {
      isLoggedIn = result;
    });
  }

  @override
  void initState() {
    isLoggedInFn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = 310;

    double width = 310;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        Get.off(() => isLoggedIn ? const HomeScreen() : const LoginScreen());
      });
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_magic.png',
              height: height,
              width: width, 
            ),
          ],
        ),
      ),
    );
  }
}
