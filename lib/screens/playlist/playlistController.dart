import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:magic_sign_mobile/screens/model/Playlist.dart';
import 'package:magic_sign_mobile/screens/model/PlaylistRessource.dart';
import 'package:magic_sign_mobile/screens/model/Playlists.dart';
import 'package:magic_sign_mobile/screens/model/Regions.dart';
import 'package:magic_sign_mobile/screens/model/Timeline.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PlaylistController extends GetxController {
  final String apiUrl =
      "https://magic-sign.cloud/v_ar/web/api/layout?embed=regions,playlists";
  var playlistList = <Playlist>[].obs;
  List<String> assignedMedia = [];
  List<Regions>? timelines = <Regions>[].obs;
  RxList<PlaylistRessource> playlistRessource = <PlaylistRessource>[].obs;

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
        Uri.parse(
            'https://magic-sign.cloud/v_ar/web/api/playlist/library/assign/$playlistId'),
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
      String url =
          'https://magic-sign.cloud/v_ar/web/api/layout/status/$layoutId';
      print('Request URL: $url');

      http.Response response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        Timeline timeline = Timeline.fromJson(jsonData);
        print('timeline');
        print(timeline.regions.toString());
        timelines = timeline.regions;
        Regions regions = timeline.regions![0];
        print('regions');

        print(regions.playlists);

        Playlists playlist = regions.playlists![0];
        print('playlists');

        print(playlist);

        print('widgets');

        print(playlist.widgets![0].toString());
      } else {
        print('Response status code not 200');
      }
    } catch (e) {
      print(e);
    }
  }

  addLayout({
    required String name,
    String? description,
  }) async {
    try {
      String? accessToken = await getAccessToken();
      final response = await http.post(
        Uri.parse('https://magic-sign.cloud/v_ar/web/api/layout'),
        body: {
          'name': name,
          if (description != null) 'description': description,
        },
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
      );

      if (response.statusCode == 201) {
        // Layout added successfully
        print('Layout added successfully');
      } else {
        // Handle error response
        print('Failed to add layout. Status code: ${response.statusCode}');
        throw Exception('Failed to add layout');
      }
    } catch (e) {
      // Handle exceptions
      print('Error adding layout: $e');
    }
  }

  getTemplate() async {
    try {
      String? accessToken = await getAccessToken();
      final response = await http.get(
        Uri.parse('https://magic-sign.cloud/v_ar/web/api/template'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        print('get template successfully');
      } else {
        print('Failed to get template. Status code: ${response.statusCode}');
        throw Exception('Failed to get template');
      }
    } catch (e) {
      // Handle exceptions
      print('Error get template: $e');
    }
  }

  getWidget() async {
    String? accessToken = await getAccessToken();
    try {
      final response = await http.get(
        Uri.parse('https://magic-sign.cloud/v_ar/web/api/playlist/widget'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData is List) {
          List<PlaylistRessource> playlistResources =
              jsonData.map((item) => PlaylistRessource.fromJson(item)).toList();

          // Assign the list to the RxList
          playlistRessource.value = playlistResources;
        } else {
          print('Response is not a list.');
        }

        print('get widget data successfully');
      } else {
        print('Failed to widget data. Status code: ${response.statusCode}');
        throw Exception('Failed to widget data');
      }
    } catch (e) {
      // Handle exceptions
      print('Error widget data: $e');
    }
  }
}
