import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:magic_sign_mobile/screens/home_screen/home_screen.dart';
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
      "client_id": "xpFXul0aZEVcNbXZaMfMZS6XcUivtI5xhFFyBaps",
      "client_secret":
          "6KtHovsZM52sW9dvYKhYTHXhTyCbEXWpyST5niIvtLKBQw8tiYai1xrCtGdimzTjIe7nUMVtPgY5KiK3WipDTDOxZl0De8AhOwzZI5bhFsEEwuQklXbU2xHH3lbiCdQiEFniqN2p0f2HCpOtzifABrJvgPsXNP12WrVuybdGv4Pj6IpcJflrrQ4spOwiwDOHr3boiQkA2tTthyV7yTjl8qctb4zNPnU7NHnMnuCYguE6hLATxIbvCY4Pz3yP0J"
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
        Get.snackbar('Login Successful', 'Welcome!',
            backgroundColor: Colors.green);
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

  


}
