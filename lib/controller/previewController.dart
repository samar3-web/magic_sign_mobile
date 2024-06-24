import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/model/Media.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../model/Timeline.dart';

class Previewcontroller extends GetxController {
  var mediasList = [].obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    print(
        'Access Token stored  *********: $accessToken'); // Print the access token
    return accessToken;
  }

  getAssignedMedia(int layoutId) async {
    this.mediasList.clear();
    try {
      String? accessToken = await getAccessToken();
      String url =
          'https://magic-sign.cloud/v_ar/web/api/objects_timeline.php?layoutId=$layoutId';
      print('Request URL: $url');

      http.Response response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);

        jsonData.forEach((key, value) {
          int timelineId =
              key != null ? int.tryParse(key.toString()) ?? -1 : -1;
          Media timeline = Media.fromJson(value);
          mediasList.add(timeline);
        });
      } else {}
    } catch (e) {
      print('Error: $e');
    }
    return mediasList.value;
  }
}
