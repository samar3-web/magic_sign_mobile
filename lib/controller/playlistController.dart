import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:magic_sign_mobile/model/Playlist.dart';
import 'package:magic_sign_mobile/model/PlaylistRessource.dart';
import 'package:magic_sign_mobile/model/Playlists.dart';
import 'package:magic_sign_mobile/model/Regions.dart';
import 'package:magic_sign_mobile/model/Timeline.dart';
import 'package:magic_sign_mobile/model/Zone.dart';
import 'package:magic_sign_mobile/screens/playlist/playlist_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PlaylistController extends GetxController {
  final String apiUrl =
      "https://magic-sign.cloud/v_ar/web/api/layout?embed=regions,playlists";
  var playlistList = <Playlist>[].obs;

  List<String> assignedMedia = [];
  RxList<Timeline> timelines = <Timeline>[].obs;
  RxList<PlaylistRessource> playlistRessource = <PlaylistRessource>[].obs;
  RxInt playlistDuration = 0.obs;
  var isLoading = false.obs;
  var originalPlaylistList = <Playlist>[].obs;
  var selectedPlaylist = ''.obs;
  var currentPage = 0.obs;
  final int pageSize = 20;

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    print(
        'Access Token stored  *********: $accessToken'); // Print the access token
    return accessToken;
  }

  Future<void> getPlaylist({int start = 0, int length = 200}) async {
    try {
      isLoading(true);
      String? accessToken = await getAccessToken();
      if (accessToken == null) {
        Get.snackbar(
          "Error",
          "Access token not available. Please log in again.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final response = await http.get(
        Uri.parse('$apiUrl?start=$start&length=$length'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body) as List?;
        if (jsonData != null) {
          var playlists = jsonData.map((e) => Playlist.fromJson(e)).toList();
          if (start == 0) {
            playlistList.assignAll(playlists);
          } else {
            playlistList.addAll(playlists);
          }
          print('Fetched playlists: $playlists'); // Debug print
        } else {
          print('Response body is null or not a list');
        }
      } else {
        print('Failed to load playlist. Status code: ${response.statusCode}');
        Get.snackbar(
          "Error",
          "Failed to load playlist. Status code: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error fetching playlist: $e');
      Get.snackbar(
        "Error",
        "Error fetching playlist. Please try again later.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  void loadMorePlaylist() {
    if (!isLoading.value) {
      currentPage.value += 1;
      getPlaylist(start: currentPage.value * pageSize, length: pageSize);
    }
  }

  Future<void> assignPlaylist(List<int> mediaIds, int playlistId,
      {Function? onSuccess, Function? onError}) async {
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
        onSuccess?.call();
      } else {
        print('Failed to assign playlist. Status code: ${response.statusCode}');
        onError?.call();
        throw Exception('Failed to assign playlist');
      }
    } catch (e) {
      print('Error assigning playlist: $e');
      onError?.call();
    }
  }

  Future<void> getAssignedMedia(int layoutId) async {
    this.timelines.clear();
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
        List<Timeline> fetchedTimelines = [];

        jsonData.forEach((key, value) {
          int timelineId =
              key != null ? int.tryParse(key.toString()) ?? -1 : -1;
          Timeline timeline = Timeline.fromJson(timelineId, value);
          fetchedTimelines.add(timeline);

          print(
              'Timeline ID: ${timeline.timelineId} has ${timeline.mediaList.length} media items');
        });
        print(timelines.length);
        this.timelines.assignAll(fetchedTimelines);
        print("Updated timelines, new count: ${this.timelines.length}");
      } else {
        print('Response status code not 200');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<Map<String, List<Zone>>> fetchZones(int layoutId) async {
    var url = Uri.parse(
        'https://magic-sign.cloud/v_ar/web/api/dimensions_timeline.php?layoutId=$layoutId');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      Map<String, List<Zone>> zones = {};
      jsonResponse.forEach((key, value) {
        List<Zone> zoneList =
            (value as List).map((item) => Zone.fromJson(item)).toList();
        zones[key] = zoneList;
      });
      return zones;
    } else {
      throw Exception('Failed to load zone dimensions');
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
        Get.to(PlaylistDetail(
            playlist: Playlist.fromJson(jsonDecode(response.body))));
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
          print(playlistResources.first);
        } else {
          print('Response is not a list.');
        }

        print('get widget data successfully');
        print(playlistRessource);
      } else {
        print('Failed to widget data. Status code: ${response.statusCode}');
        throw Exception('Failed to widget data');
      }
    } catch (e) {
      // Handle exceptions
      print('Error widget data: $e');
    }
  }

  editWidget(int widgetId, String duration) async {
    try {
      Map<String, dynamic> body = {
        'duration': duration.toString(),
      };
      String? accessToken = await getAccessToken();
      http.Response response = await http.put(
        Uri.parse(
            'https://magic-sign.cloud/v_ar/web/api/playlist/widget/$widgetId'),
        body: body,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
      } else {
        print('response status code not 200');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteWidget(int widgetId) async {
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

      final response = await http.delete(
        Uri.parse(
            'https://magic-sign.cloud/v_ar/web/api/playlist/widget/$widgetId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          "Succès",
          "widget suprrimé avec succès",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        print('Failed to delete widget. Status code: ${response.statusCode}');
        Get.snackbar(
          "Error",
          "Failed to delete widget. Status code: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error deleting widget: $e');
      Get.snackbar(
        "Error",
        "Error deleting widget. Please try again later.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updatePlaylistDuration(int layoutId, String newDuration) async {
    try {
      String? accessToken = await getAccessToken();
      http.Response response = await http.put(
        Uri.parse('https://magic-sign.cloud/v_ar/web/api/layout/$layoutId'),
        body: {'duration': newDuration},
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      if (response.statusCode == 200) {
        print('Playlist duration updated successfully');
      } else {
        print('Failed to update playlist duration');
      }
    } catch (e) {
      print('Error updating playlist duration: $e');
    }
  }

  editLayout(int layoutId, String name) async {
    try {
      Map<String, dynamic> body = {
        'name': name,
      };

      String? accessToken = await getAccessToken();
      http.Response response = await http.put(
        Uri.parse('https://magic-sign.cloud/v_ar/web/api/layout/$layoutId'),
        body: body,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
      } else {
        print('response status code not 200');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteLayout(int layoutId) async {
    try {
      String? accessToken = await getAccessToken();
      http.Response response = await http.delete(
        Uri.parse('https://magic-sign.cloud/v_ar/web/api/layout/$layoutId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 204) {
        print('Layout deleted successfully');
      } else {
        print('Failed to delete layout');
      }
    } catch (e) {
      print(e);
    }
  }
  //search

  Future<void> searchPlaylist(String value) async {
    try {
      isLoading(true);

      String? accessToken = await getAccessToken();
      if (accessToken == null) {
        Get.snackbar(
          "Error",
          "Access token not available. Please log in again.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final response = await http.get(
        Uri.parse('https://magic-sign.cloud/v_ar/web/api/layout?layout=$value'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = (json.decode(response.body) as List)
            .map((e) => Playlist.fromJson(e))
            .toList();

        print(jsonData);
        playlistList.assignAll(jsonData);
        originalPlaylistList.assignAll(jsonData);
      } else {
        print('Failed to search playlist. Status code: ${response.statusCode}');
        Get.snackbar(
          "Error",
          "Failed to search playlist. Status code: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error searching playlist: $e');
      Get.snackbar(
        "Error",
        "Error searching playlist. Please try again later.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> scheduleEvent(int campaignId, List<int> displayGroupIds,
      String fromDt, String toDt) async {
    try {
      String? accessToken = await getAccessToken();

      var body = {
        'eventTypeId': "1",
        'isPriority': "0",
        'displayOrder': "0",
        'syncTimezone': "1",
        'campaignId': campaignId.toString(),
        'displayGroupIds[]': displayGroupIds[0].toString(),
        'fromDt': fromDt.toString() + "",
        'toDt': toDt.toString() + "",
      };
      print('Request Body');
      print(body);
//print(jsonEncode(body));
      http.Response response = await http.post(
        Uri.parse('https://magic-sign.cloud/v_ar/web/api/schedule'),
        body: body,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      print(response.body);

      if (response.statusCode == 201) {
        print(response.body);
      } else {
        print('Erreur: ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur: $error');
    }
  }
}
