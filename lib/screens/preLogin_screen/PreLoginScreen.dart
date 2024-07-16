import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/screens/login_screen/login_screen.dart';

class Preloginscreen extends StatefulWidget {
  const Preloginscreen({super.key});

  @override
  State<Preloginscreen> createState() => _PreloginscreenState();
}

class _PreloginscreenState extends State<Preloginscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo_magic.png',
                  height: 200.0,
                  width: 200.0,
                ),
                SizedBox(height: 50),
                TextField(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'CMS URL',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Get.to(LoginScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
