import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:magic_sign_mobile/screens/home_screen/home_screen.dart';
import 'package:magic_sign_mobile/screens/login_screen/login_screen.dart';

class LoginController extends GetxController {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  Timer? _timer; 
  bool isRefreshingToken = false;

  Future<void> login() async {
    var url = "https://magic-sign.cloud/v_ar/web/api/authorize/access_token";
    Map<String, dynamic> body = {
      "username": username.text,
      "password": password.text,
      "grant_type": "client_credentials",
      "client_id": "xpFXul0aZEVcNbXZaMfMZS6XcUivtI5xhFFyBaps",
      "client_secret":
          "6KtHovsZM52sW9dvYKhYTHXhTyCbEXWpyST5niIvtLKBQw8tiYai1xrCtGdimzTjIe7nUMVtPgY5KiK3WipDTDOxZl0De8AhOwzZI5bhFsEEwuQklXbU2xHH3lbiCdQiEFniqN2p0f2HCpOtzifABrJvgPsXNP12WrVuybdGv4Pj6IpcJflrrQ4spOwiwDOHr3boiQkA2tTthyV7yTjl8qctb4zNPnU7NHnMnuCYguE6hLATxIbvCY4Pz3yP0J"
    };

    var response = await http.post(
      Uri.parse(url),
      body: body,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      try {
        var data = jsonDecode(response.body);
        var accessToken = data['access_token'];
        var tokenType = data['token_type'];
        var expiresIn = data['expires_in']; 
        var expiryDate = DateTime.now().add(Duration(seconds: expiresIn));
        await saveAccessToken(accessToken, expiryDate);
        await saveCredentials(username.text, password.text); 

        print('**********response data *********');
        print(accessToken);
        print(tokenType);
        print(expiresIn);
        print('**********response data *********');

        await verifyCredentials(accessToken, username.text, password.text);

        username.clear();
        password.clear();

        // Schedule the token refresh
        scheduleTokenRefresh(expiresIn);
      } catch (error) {
        print("Parsing Error: $error");
      }
    } else {
      print("Login Failed");
      Get.snackbar('La connexion a échoué',
          'Nom d\'utilisateur ou mot de passe incorrect',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void scheduleTokenRefresh(int expiresIn) {
    _timer?.cancel();

    int refreshInterval = expiresIn - 60;
    if (refreshInterval > 0) {
      _timer = Timer(Duration(seconds: refreshInterval), refreshAccessToken);
    }
  }

  Future<void> refreshAccessToken() async {
    if (isRefreshingToken) return; 
    isRefreshingToken = true;

    print('Attempting to refresh token...');
    var url = "https://magic-sign.cloud/v_ar/web/api/authorize/access_token";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');

    if (username != null && password != null) {
      Map<String, dynamic> body = {
        "username": username,
        "password": password,
        "grant_type": "client_credentials",
        "client_id": "xpFXul0aZEVcNbXZaMfMZS6XcUivtI5xhFFyBaps",
        "client_secret":
            "6KtHovsZM52sW9dvYKhYTHXhTyCbEXWpyST5niIvtLKBQw8tiYai1xrCtGdimzTjIe7nUMVtPgY5KiK3WipDTDOxZl0De8AhOwzZI5bhFsEEwuQklXbU2xHH3lbiCdQiEFniqN2p0f2HCpOtzifABrJvgPsXNP12WrVuybdGv4Pj6IpcJflrrQ4spOwiwDOHr3boiQkA2tTthyV7yTjl8qctb4zNPnU7NHnMnuCYguE6hLATxIbvCY4Pz3yP0J"
      };

      var response = await http.post(
        Uri.parse(url),
        body: body,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        try {
          var data = jsonDecode(response.body);
          var accessToken = data['access_token'];
          var tokenType = data['token_type'];
          var expiresIn = data['expires_in'];
          var expiryDate = DateTime.now().add(Duration(seconds: expiresIn));
          await saveAccessToken(accessToken, expiryDate);

          print('Token refreshed successfully');
          print('New Access Token: $accessToken');
          print('Expires In: $expiresIn seconds');

          scheduleTokenRefresh(expiresIn);
        } catch (error) {
          print("Parsing Error: $error");
        }
      } else {
        print("Token refresh failed");
      }
    } else {
      print("Username or password not found in SharedPreferences");
    }
    isRefreshingToken = false;
  }

  Future<void> verifyCredentials(
      String accessToken, String username, String password) async {
    var url =
        "https://magic-sign.cloud/v_ar/web/api/login_ws/$username/$password";
    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['authentication'] == 'true') {
        Get.to(() => HomeScreen());
      } else {
        Get.snackbar('La connexion a échoué',
            'Nom d\'utilisateur ou mot de passe incorrect',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      Get.snackbar('La connexion a échoué', 'Erreur d\'authentification',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> saveAccessToken(String token, DateTime expiryDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    await prefs.setString('expiry_date', expiryDate.toIso8601String());
  }

  Future<void> saveCredentials(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
  }

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    String? expiryDateString = prefs.getString('expiry_date');
    if (token != null && expiryDateString != null) {
      DateTime expiryDate = DateTime.parse(expiryDateString);
      if (DateTime.now().isBefore(expiryDate)) {
        print('Token is still valid');
        return token;
      } else {
        print('Token has expired');
        await clearAccessToken();
      }
    } else {
      print('No token found');
    }
    return null;
  }

  Future<void> clearAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('expiry_date');
    print('Access Token cleared');
  }

  Future<List<dynamic>> fetchUsers() async {
    String? accessToken = await getAccessToken();

    if (accessToken == null) {
      await refreshAccessToken();
      accessToken = await getAccessToken();
    }

    final response = await http
        .get(Uri.parse('https://magic-sign.cloud/v_ar/web/api/user'), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    String? accessToken = await getAccessToken();

    if (accessToken == null) {
      await refreshAccessToken();
      accessToken = await getAccessToken();
    }

    final response = await http.get(
        Uri.parse('https://magic-sign.cloud/v_ar/web/api/user/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        });

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user');
    }
  }

  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('username'); 
    await prefs.remove('password'); 
    print('Access Token Removed');
    Get.offAll(() => LoginScreen());
  }
}
