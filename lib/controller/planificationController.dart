import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:magic_sign_mobile/controller/connectionController.dart';
import 'package:magic_sign_mobile/model/Player.dart';
import 'package:magic_sign_mobile/model/Playlist.dart';
import 'package:magic_sign_mobile/screens/planification/planification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sqlitedb/magic_sign_db.dart';

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
    print('Access Token stored  *********: $accessToken');
    return accessToken;
  }


  Future<List<Map<String, dynamic>>> fetchScheduleEvent() async {
    var isConnected = await Connectioncontroller.isConnected();
    if (isConnected) {
      String? accessToken = await getAccessToken();
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
          List<Map<String, dynamic>> events =
              List<Map<String, dynamic>>.from(data['records'].map((event) {
            return {
              'eventID': event['eventID'],
              'eventTypeId': event['eventTypeId'],
              'CampaignID': event['CampaignID'],
              'userID': event['userID'],
              'is_priority': event['is_priority'],
              'start_time': DateTime.fromMillisecondsSinceEpoch(
                  int.parse(event['FromDT']) * 1000),
              'end_time': DateTime.fromMillisecondsSinceEpoch(
                  int.parse(event['ToDT']) * 1000),
              'DisplayOrder': event['DisplayOrder'],
              'DisplayGroupID': event['DisplayGroupID'],
              'dayPartId': event['dayPartId'],
            };
          }).toList());

          for (var event in events) {
            await MagicSignDB().createEvent(event, 1);
          }
          return events;
        } else {
          throw Exception(
              'Failed to load schedule events: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Failed to load schedule events: $e');
      }
    } else {
      Get.snackbar("OFFLINE MODE", "you are in the offline mode");
      var events = await MagicSignDB().fetchScheduleEvent();
      return events;
    }
  }

}
