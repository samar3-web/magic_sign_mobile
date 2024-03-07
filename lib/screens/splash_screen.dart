import 'package:flutter/material.dart';
import 'package:magic_sign_mobile/screens/login_screen/login_screen.dart';
import 'package:sizer/sizer.dart';

class splashScreen extends StatelessWidget {
  static String routeName = 'SplashScreen';

  const splashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double height = 310; // Initialize height with a default value

    double width = 310; // Initialize height with a default value

    // Using WidgetsBinding.instance!.addPostFrameCallback() to execute navigation after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.pushNamedAndRemoveUntil(
            context, LoginScreen.routeName, (route) => false);
      });
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_magic.png',
              height: height, // Using Sizer's percentage height
              width: width,  // Using Sizer's percentage width
            ),
          ],
        ),
      ),
    );
  }
}
