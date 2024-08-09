import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/loginController.dart';
import 'package:magic_sign_mobile/screens/login_screen/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preloginscreen extends StatefulWidget {
  const Preloginscreen({super.key});

  @override
  State<Preloginscreen> createState() => _PreloginscreenState();
}

class _PreloginscreenState extends State<Preloginscreen> {
  final LoginController controller = Get.put(LoginController());

  @override
  void initState() {
    super.initState();
    _printServerUrlsLength();
  }

  Future<void> _printServerUrlsLength() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> serverUrls = prefs.getStringList('base_url') ?? [];
    print('Length of stored base URL list: ${serverUrls.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
                controller: controller.baseUrlController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: kTextLightColor),
                  ),
                  labelText: 'CMS URL',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: kSecondaryColor,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: kTextLightColor,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                controller: controller.clientIdController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: kTextLightColor),
                  ),
                  labelText: 'Client ID',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: kSecondaryColor,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: kTextLightColor,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                controller: controller.clientSecretController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: kTextLightColor),
                  ),
                  labelText: 'Client Secret',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: kSecondaryColor,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: kTextLightColor,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: ()async {
                 await controller.setApiConfiguration();
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
    );
  }
}
