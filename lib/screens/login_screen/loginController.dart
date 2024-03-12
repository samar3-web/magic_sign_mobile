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
        print(data);
        print(accessToken);
        // Store access token securely using SharedPreferences
        storeAccessToken(accessToken);
        Get.to(() => HomeScreen());
      } catch (error) {
        print("Parsing Error: $error");
      }
    } else {
      print("Login Failed");
      // Show error message to the user
      // Get.snackbar("Login Failed", "Incorrect username or password");
    }
  }

  void storeAccessToken(String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    print('Access token stored successfully');
  }

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  @override
  void onInit() {
    super.onInit();
    // Check if access token is already stored during app initialization
    getAccessToken().then((accessToken) {
      if (accessToken != null && accessToken.isNotEmpty) {
        // Access token exists, navigate to home screen directly
        Get.off(() => HomeScreen());
      }
    });
  }
}
