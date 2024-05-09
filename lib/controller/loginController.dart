import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:magic_sign_mobile/screens/home_screen/home_screen.dart';
import 'package:magic_sign_mobile/screens/login_screen/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  login() async {
    var url = "https://magic-sign.cloud/v_ar/web/api/authorize/access_token";
    Map<String, dynamic> body = {
      "username": username.text,
      "password": password.text,
      "grant_type": "client_credentials",
      "client_id": "RfLCI42cY8mkBlU8pYeYH7WB6Jb0BUddPKBlq0Wk",
      " client_secret": "rsfhZasvCPk6ObQ7g5WykvOhYyELqEFHEm7MznJ4BsFMJXmquCgmt5nimwPk5tY8GXnosgd9pJ2Awbwk4GcmDhGlCgKXzc5mIbGsbVZ115Z5D7P24mUn5kOQCNupAd373B4bmB5lOhE9zqklQQO9gv1tXnJGru8KZlFwdjP47JVAXirzhSClXSlERlyO72FwjWLP7EBEa4PK2eRGHTrCmjxXEbwVKJ4H9ydSIhtdDV6D7m38EWAeYQRXjDBmFH"
      
    };
    var response = await http.post(Uri.parse(url), body: body, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    });

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      try {
        var data = jsonDecode(response.body);
        var accessToken = data['access_token'];
        var tokenType = data['token_type'];
        var expirationDate = data['expires_in'];
        print('**********response data *********');
        print(accessToken);
        print(tokenType);
        print(expirationDate);
        print('**********response data *********');

        // Store access token securely using SharedPreferences
        saveAccessToken(accessToken);

        // Affichez un snackbar pour indiquer que la connexion a réussi
        //Get.snackbar('Login Successful', 'Welcome!',
          //  backgroundColor: Colors.green);
        Get.to(() => HomeScreen());
      } catch (error) {
        print("Parsing Error: $error");
      }
    } else {
      print("Login Failed");
      // Show error message to the user
      // Affichez un snackbar pour indiquer que la connexion a échoué
      Get.snackbar('Login Failed', 'Incorrect username or password',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> saveAccessToken(String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
      await prefs.setString('access_token', accessToken);
      print('Access Token Saved: $accessToken');

    
  }

  
 logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    print('Access Token Removed');
    Get.offAll(() => LoginScreen());
  }

}
