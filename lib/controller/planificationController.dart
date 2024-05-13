import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PlanificationController extends GetxController {
  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    print(
        'Access Token stored  *********: $accessToken'); // Print the access token
    return accessToken;
  }

  Future<List<dynamic>> fetchScheduleEvents(
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
  }

  Future fetchScheduleEvent() async {
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
        print('all events fetched ');
      } else {
        throw Exception(
            'Failed to load schedule events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load schedule events: $e');
    }
  }
}
