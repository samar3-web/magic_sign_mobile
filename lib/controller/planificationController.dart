import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:magic_sign_mobile/model/Playlist.dart';
import 'package:magic_sign_mobile/screens/planification/planification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlanificationController extends GetxController {
    late AppointmentDataSource appointmentsDataSource;
    RxList<Playlist> playlistList = <Playlist>[].obs;

     PlanificationController() {
    appointmentsDataSource = AppointmentDataSource([]);
  }
   Future<List<Map<String, dynamic>>> fetchScheduleEvents() async {
    return await fetchScheduleEvent();
  }

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    print(
        'Access Token stored  *********: $accessToken'); 
    return accessToken;
  }

 /* Future<List<dynamic>> fetchScheduleEvents(
      List<int> displayGroupIds, String date) async {
    String? accessToken = await getAccessToken();
    print('Access Token: $accessToken');
    if (accessToken == null) {
      Get.snackbar(
        "Error",
        "Access token not available. Please log in again.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return [];
    }

    final displayGroupIdsQuery =
        displayGroupIds.map((id) => 'displayGroupId[]=$id').join('&');
    final apiUrl =
        'https://magic-sign.cloud/v_ar/web/api/schedule/$displayGroupIdsQuery/events?date=$date';

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      });

      print(response.body);

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        if (responseData is List<dynamic>) {
          return responseData;
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('events')) {
          return responseData['events'];
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
            'Failed to load schedule events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load schedule events: $e');
    }
  }*/

  Future<List<Map<String, dynamic>>> fetchScheduleEvent() async {
  String? accessToken = await getAccessToken();
  print('Access Token: $accessToken');
  if (accessToken == null) {
    Get.snackbar(
      "Error",
      "Access token not available. Please log in again.",
      snackPosition: SnackPosition.BOTTOM,
    );
    return [];
  }

  const apiUrl = 'https://magic-sign.cloud/v_ar/web/api/events.php';

  try {
    final response = await http.get(Uri.parse(apiUrl), headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    });

    print(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Map<String, dynamic>> events = List<Map<String, dynamic>>.from(data['records'].map((event) {
        return {
          'eventID': event['eventID'],
          'eventTypeId': event['eventTypeId'],
          'CampaignID': event['CampaignID'],
          'userID': event['userID'],
          'is_priority': event['is_priority'],
           'start_time': DateTime.fromMillisecondsSinceEpoch(int.parse(event['FromDT']) * 1000),
          'end_time': DateTime.fromMillisecondsSinceEpoch(int.parse(event['ToDT']) * 1000),
          'DisplayOrder': event['DisplayOrder'],
          'DisplayGroupID': event['DisplayGroupID'],
          'dayPartId': event['dayPartId'],
        };
      }).toList());

      print('All events fetched');
      return events;
    } else {
      throw Exception('Failed to load schedule events: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to load schedule events: $e');
  }
}

Future<void> getPlaylist() async {
  try {
    String? accessToken = await getAccessToken();
    print('Access Token: $accessToken');
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
      Uri.parse("https://magic-sign.cloud/v_ar/web/api/layout"),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      // Handle successful response
      var jsonData = json.decode(response.body) as List?;
      if (jsonData != null) {
        var playlists = jsonData.map((e) => Playlist.fromJson(e)).toList();
       playlistList.assignAll(playlists); 
       print('Response Body: ${response.body}');
print('Playlist List: $playlistList');
      } else {
        print('Response body is null or not a list');
      }
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
  }
}

String getPlaylistName(int playlistId) {
  var playlist = playlistList.firstWhere((playlist) => playlist.campaignId == playlistId, orElse: () => Playlist(layoutId: 0, campaignId: 0, layout: '', status: '', duration: '', owner: '', playlistId: 0, regions: []));
  print('Playlist ID: $playlistId');
print(playlist.layout);
  return playlist.layout;
}



}
