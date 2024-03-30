import 'dart:convert';

import 'package:get/get.dart';
import 'package:magic_sign_mobile/screens/model/Playlist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PlaylistController extends GetxController {
  final String apiUrl =
      "https://magic-sign.cloud/v_ar/web/api/layout?embed=regions,playlists";
  var playlistList = <Playlist>[].obs;

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    print(
        'Access Token stored  *********: $accessToken'); // Print the access token
    return accessToken;
  }

  Future<void> getPlaylist() async {
    try {
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
            .map((e) => Playlist.fromJson(e))
            .toList();
        // You can process the jsonData as per your requirement
        // print(jsonData);
        jsonData.forEach((element) {
          print(element.layout);
        });
        // Update mediaList with fetched data
        playlistList.assignAll(jsonData);
      } else {
        // Handle error response
        print('Failed to load playlist. Status code: ${response.statusCode}');
        Get.snackbar(
          "Error",
          "Failed to load playlist. Status code: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Handle exceptions
      print('Error fetching playlist: $e');
      Get.snackbar(
        "Error",
        "Error fetching playlist. Please try again later.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {}
  }

  Future<void> assignPlaylist(List<int> mediaIds, int playlistId) async {
  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      Get.snackbar(
        "Error",
        "Access token not available. Please log in again.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://magic-sign.cloud/v_ar/web/api/playlist/library/assign/$playlistId'),
    );

    request.headers['Content-Type'] = 'application/x-www-form-urlencoded';
    request.headers['Authorization'] = 'Bearer $accessToken';

    for (int mediaId in mediaIds) {
      request.fields['media[]'] = mediaId.toString();
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      print('Playlist assigned successfully');
    } else {
      print('Failed to assign playlist. Status code: ${response.statusCode}');
      throw Exception('Failed to assign playlist');
    }
  } catch (e) {
    print('Error assigning playlist: $e');
  }
}

Future<void> getAssignedMedia(int layoutId) async {
  try {
    String? accessToken = await getAccessToken();
    String url = 'https://magic-sign.cloud/v_ar/web/api/layout/status/$layoutId';
    print('Request URL: $url');

    http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken'
      },
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      List<dynamic> regions = jsonData['regions'];
      for (var region in regions) {
        List<dynamic> playlists = region['playlists'];
        for (var playlist in playlists) {
          List<dynamic> widgets = playlist['widgets'];
          for (var widget in widgets) {
            int widgetId = widget['widgetId'];
            int playlistId = widget['playlistId'];
            String type = widget['type'];
            int duration = widget['duration'];
            String displayOrder = widget['displayOrder'];
            // Access other attributes as needed
            print('Widget ID: $widgetId');
            print('Playlist ID: $playlistId');
            print('Type: $type');
            print('Duration: $duration');
            print('Display Order: $displayOrder');
            // Access widget options if needed
            List<dynamic> widgetOptions = widget['widgetOptions'];
            for (var option in widgetOptions) {
              String optionType = option['type'];
              String optionName = option['option'];
              String optionValue = option['value'];
              print('Widget Option Type: $optionType');
              print('Widget Option Name: $optionName');
              print('Widget Option Value: $optionValue');
            }
            // Access mediaIds if available
            List<dynamic> mediaIds = widget['mediaIds'];
            for (var mediaId in mediaIds) {
              print('Media ID: $mediaId');
            }
          }
        }
      }
    } else {
      print('Response status code not 200');
    }
  } catch (e) {
    print(e);
  }
}

}
