import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:magic_sign_mobile/screens/home_screen/home_screen.dart';
import 'package:magic_sign_mobile/screens/model/Media.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MediaController extends GetxController {
  final String apiUrl = "https://magic-sign.cloud/v_ar/web/api/library";

  // Define isLoading property to handle loading state
  var isLoading = false.obs;

  // Function to retrieve the access token from SharedPreferences
  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    print('Access Token: $accessToken'); // Print the access token
    return accessToken;
  }

  // Function to fetch media using the access token for authorization
  Future<void> getMedia() async {
    try {
      // Set isLoading to true before making the request
      isLoading(true);

      String? accessToken = await getAccessToken();
      if (accessToken == null) {
        // Handle case when access token is not available
        Get.snackbar(
          "Error",
          "Access token not available. Please log in again.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Handle successful response
        var jsonData = (json.decode(response.body) as List)
            .map((e) => Media.fromJson(e))
            .toList();
        // You can process the jsonData as per your requirement
        // print(jsonData);
        jsonData.forEach((element) {
          print(element.name);
        });
      } else {
        // Handle error response
        print('Failed to load media. Status code: ${response.statusCode}');
        Get.snackbar(
          "Error",
          "Failed to load media. Status code: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Handle exceptions
      print('Error fetching media: $e');
      Get.snackbar(
        "Error",
        "Error fetching media. Please try again later.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      // Set isLoading to false after request completes (whether success or failure)
      isLoading(false);
    }
  }
}
