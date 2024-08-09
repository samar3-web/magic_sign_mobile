import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:magic_sign_mobile/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:magic_sign_mobile/screens/home_screen/home_screen.dart';
import 'package:magic_sign_mobile/screens/login_screen/login_screen.dart';

class LoginController extends GetxController {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  TextEditingController baseUrlController = TextEditingController();
  TextEditingController clientIdController = TextEditingController();
  TextEditingController clientSecretController = TextEditingController();
  Timer? _timer;
  bool isRefreshingToken = false;

  @override
  void onInit() {
    super.onInit();
    _loadBaseUrl();
  }

  Future<void> setApiConfiguration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String baseUrl = baseUrlController.text.trim();
    String clientId = clientIdController.text.trim();
    String clientSecret = clientSecretController.text.trim();

    if (baseUrl.isEmpty || clientId.isEmpty || clientSecret.isEmpty) {
      Get.snackbar('Configuration Error',
          'Base URL, Client ID, and Client Secret cannot be empty');
      return;
    }

    List<String> baseUrlList = prefs.getStringList('base_url') ?? [];
    List<String> clientIdList = prefs.getStringList('client_id') ?? [];
    List<String> clientSecretList = prefs.getStringList('client_secret') ?? [];

    // Append new server information
    baseUrlList.add(baseUrl);
    clientIdList.add(clientId);
    clientSecretList.add(clientSecret);

    // Store updated lists
    await prefs.setStringList('base_url', baseUrlList);
    await prefs.setStringList('client_id', clientIdList);
    await prefs.setStringList('client_secret', clientSecretList);

    // Initialize ApiConfig
    ApiConfig.baseUrl = baseUrlList;
    ApiConfig.clientId = clientIdList;
    ApiConfig.clientSecret = clientSecretList;

    print("Base URLs: ${ApiConfig.baseUrl}");
    print("Client IDs: ${ApiConfig.clientId}");
    print("Client Secrets: ${ApiConfig.clientSecret}");
  }

  String _getFullUrl(String baseUrl, String endpoint) {
    if (!baseUrl.startsWith(RegExp(r'https?://'))) {
      throw Exception('Base URL does not start with a valid scheme');
    }

    if (!baseUrl.endsWith('/')) {
      baseUrl = '$baseUrl/';
    }

    if (endpoint.startsWith('/')) {
      endpoint = endpoint.substring(1);
    }

    String fullUrl = '$baseUrl$endpoint';
    print('Debug: Full URL = $fullUrl');

    return Uri.parse(fullUrl).toString();
  }

  String get baseUrl {
    String? activeServerUrl = ApiConfig.activeServerUrl;

    if (activeServerUrl != null && activeServerUrl.isNotEmpty) {
      print('Using active server URL: $activeServerUrl');
      return activeServerUrl;
    }

    List<String> baseUrls = ApiConfig.baseUrl ?? [];
    if (baseUrls.isNotEmpty) {
      print('Using last base URL: ${baseUrls.last}');
      return baseUrls.last;
    }

    String fallbackUrl = baseUrlController.text.trim();
    print('Using fallback base URL: $fallbackUrl');
    return fallbackUrl;
  }

  Future<void> _loadBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? url = prefs.getStringList('base_url');
    List<String>? clientId = prefs.getStringList('client_id');
    List<String>? clientSecret = prefs.getStringList('client_secret');

    if (url == null || clientId == null || clientSecret == null) {
      return;
    }

    baseUrlController.text = url.join(', ');
    clientIdController.text = clientId.join(', ');
    clientSecretController.text = clientSecret.join(', ');

    ApiConfig.baseUrl = url;
    ApiConfig.clientId = clientId;
    ApiConfig.clientSecret = clientSecret;
  }

  Future<void> login() async {
    if (ApiConfig.clientId == null || ApiConfig.clientId!.isEmpty) {
      Get.snackbar('Configuration Error', 'Client ID is not set');
      return;
    }
    if (ApiConfig.clientSecret == null || ApiConfig.clientSecret!.isEmpty) {
      Get.snackbar('Configuration Error', 'Client Secret is not set');
      return;
    }

    String selectedBaseUrl = ApiConfig.baseUrl!.last;
    String clientId = ApiConfig.clientId!.last;
    String clientSecret = ApiConfig.clientSecret!.last;
    var url = _getFullUrl(selectedBaseUrl, '/web/api/authorize/access_token');

    Map<String, dynamic> body = {
      "username": username.text,
      "password": password.text,
      "grant_type": "client_credentials",
      "client_id": clientId,
      "client_secret": clientSecret
    };

    var response = await http.post(
      Uri.parse(url),
      body: body,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    print(url);

    if (response.statusCode == 200) {
      try {
        var data = jsonDecode(response.body);
        var accessToken = data['access_token'];
        var tokenType = data['token_type'];
        var expiresIn = data['expires_in'];
        var expiryDate = DateTime.now().add(Duration(seconds: expiresIn));
        await saveAccessToken(accessToken, expiryDate);
        await saveCredentials(username.text, password.text, baseUrl);
        print('**********response data *********');
        print(accessToken);
        print(tokenType);
        print(expiresIn);
        print('**********response data *********');

        await verifyCredentials(accessToken, username.text, password.text);

        username.clear();
        password.clear();
        baseUrlController.clear();
        clientIdController.clear();
        clientSecretController.clear();

        scheduleTokenRefresh(expiresIn);
      } catch (error) {
        print("Parsing Error: $error");
      }
    } else {
      print("Login Failed for $url");
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');

    if (username != null && password != null) {
      for (int i = 0; i < ApiConfig.baseUrl!.length; i++) {
        var url = _getFullUrl(
            ApiConfig.baseUrl![i], '/web/api/authorize/access_token');
        String clientId = ApiConfig.clientId![i];
        String clientSecret = ApiConfig.clientSecret![i];

        Map<String, dynamic> body = {
          "username": username,
          "password": password,
          "grant_type": "client_credentials",
          "client_id": clientId,
          "client_secret": clientSecret,
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
            var expiresIn = data['expires_in'];
            var expiryDate = DateTime.now().add(Duration(seconds: expiresIn));
            await saveAccessToken(accessToken, expiryDate);

            print('Token refreshed successfully for $url');
            print('New Access Token: $accessToken');
            print('Expires In: $expiresIn seconds');

            scheduleTokenRefresh(expiresIn);
            break;
          } catch (error) {
            print("Parsing Error: $error");
          }
        } else {
          print("Token refresh failed for $url");
        }
      }
    } else {
      print("Username or password not found in SharedPreferences");
    }
    isRefreshingToken = false;
  }

  Future<void> verifyCredentials(
      String accessToken, String username, String password) async {
    if (ApiConfig.baseUrl == null || ApiConfig.baseUrl!.isEmpty) {
      throw Exception('Base URL is not set');
    }

    String selectedBaseUrl = ApiConfig.baseUrl!.last;
    var url =
        _getFullUrl(selectedBaseUrl, '/web/api/login_ws/$username/$password');
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

  Future<void> saveCredentials(
      String username, String password, String baseUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('${baseUrl}_username', username);
    await prefs.setString('${baseUrl}_password', password);
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
  await _loadBaseUrl();

  // Get the active server URL from ApiConfig
  String? activeServerUrl = ApiConfig.activeServerUrl;

  // If no active server URL is set, fall back to the last base URL
  if (activeServerUrl == null || activeServerUrl.isEmpty) {
    List<String> baseUrls = ApiConfig.baseUrl ?? [];
    if (baseUrls.isNotEmpty) {
      activeServerUrl = baseUrls.last;
    } else {
      throw Exception('Base URL is not set and no default URL is available');
    }
  }

  String? accessToken = await getAccessToken();

  if (accessToken == null) {
    await refreshAccessToken();
    accessToken = await getAccessToken();
  }

  var url = _getFullUrl(activeServerUrl, '/web/api/user');
  final response = await http.get(Uri.parse(url), headers: {
    'Authorization': 'Bearer $accessToken',
  });

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load users from $activeServerUrl');
  }
}

 Future<Map<String, dynamic>> getUser() async {
  await _loadBaseUrl();

  // Get the active server URL from ApiConfig
  String? activeServerUrl = ApiConfig.activeServerUrl;

  // If no active server URL is set, fall back to the last base URL
  if (activeServerUrl == null || activeServerUrl.isEmpty) {
    List<String> baseUrls = ApiConfig.baseUrl ?? [];
    if (baseUrls.isNotEmpty) {
      activeServerUrl = baseUrls.last;
    } else {
      throw Exception('Base URL is not set and no default URL is available');
    }
  }

  String? accessToken = await getAccessToken();

  if (accessToken == null) {
    await refreshAccessToken();
    accessToken = await getAccessToken();
  }

  var url = _getFullUrl(activeServerUrl, '/web/api/user/me');
  final response = await http.get(Uri.parse(url), headers: {
    'Authorization': 'Bearer $accessToken',
  });

  if (response.statusCode == 200) {
    print(response.body);
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load user from $activeServerUrl');
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

  Future<void> clearApiConfiguration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('expiry_date');

    await prefs.remove('username');
    await prefs.remove('password');
    //await prefs.remove('base_url');
    // await prefs.remove('client_id');
    //await prefs.remove('client_secret');
    print('API Configuration cleared');
  }
}
