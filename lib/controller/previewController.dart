import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/controller/loginController.dart';
import 'package:magic_sign_mobile/model/PreviewTimeline.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../model/Timeline.dart';

class Previewcontroller extends GetxController {
  var mediasList = <PreviewTimeline>[].obs;
  RxList<PreviewTimeline> timelines = <PreviewTimeline>[].obs;

  LoginController loginController = Get.put(LoginController());

  String get apiUrl => loginController.baseUrl;

  @override
  void onInit() {
    super.onInit();
  }

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    print(
        'Access Token stored  *********: $accessToken'); 
    return accessToken;
  }

  fetchAssignedMedia(int layoutId) async {
    try {
      String? accessToken = await getAccessToken();
      

      http.Response response = await http.get(
        Uri.parse('${loginController.baseUrl}//web/api/objects_timeline.php?layoutId=$layoutId'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Bodyyyyyyyyyyyyyy: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        List<PreviewTimeline> fetchedTimelines = [];

        jsonData.forEach((key, value) {
          try {
            int timelineId = int.tryParse(key) ?? -1;
            if (timelineId == -1) {
              throw Exception('Invalid timeline ID: $key');
            }

            PreviewTimeline timeline =
                PreviewTimeline.fromJson(timelineId, value);
            fetchedTimelines.add(timeline);

            print(
                'Timeline ID: ${timeline.timelineId} has ${timeline.mediaList.length} media items');
          } catch (e) {
            print('Error parsing timeline with key $key: $e');
          }
        });

        mediasList.assignAll(fetchedTimelines);
        print("Updated mediasList, new count: ${mediasList.length}");
      } else {
        print('Response status code not 200');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
