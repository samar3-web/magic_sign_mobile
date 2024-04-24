import 'dart:convert';

import 'package:get/get.dart';
import 'package:magic_sign_mobile/model/DisplayGroup.dart';
import 'package:magic_sign_mobile/model/Player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PlayerController extends GetxController {
  var playerList = <Player>[].obs;
  var displayGroupList = <DisplayGroup>[].obs;
  
  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    print(
        'Access Token stored  ***********: $accessToken'); 
    return accessToken;
  }

  Future<List<dynamic>> fetchData() async {
    String apiUrl = 'https://magic-sign.cloud/v_ar/web/api/display-ms';

    try {
      String? accessToken = await getAccessToken();
      if (accessToken == null) {
        Get.snackbar(
          "Error",
          "Access token not available. Please log in again.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return []; 
      }

      http.Response response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body) as List<dynamic>;

        // Mapper les données pour récupérer les displayGroupId
        List<dynamic> displayGroupIds = [];
        jsonData.forEach((display) {
          int? displayGroupId = display['displayGroupId'];
          String? name = display['display'];

          if (displayGroupId != null && name != null) {
            Map<String, dynamic> newDisplay = {
              'id': displayGroupId,
              'name': name
            };
            displayGroupIds.add(newDisplay);
          }
        });
      print('Json Data: $jsonData');
          var jsonDataa = (json.decode(response.body) as List).map((e) => Player.fromJson(e)).toList();

          playerList.assignAll(jsonDataa);

        return displayGroupIds;
      } else {
        print('Erreur: ${response.statusCode}');
        return []; 
      }
    } catch (e) {
      print('Erreur: $e');
      return []; 
    }
  }

Future<List<DisplayGroup>> fetchDisplayGroup() async {
    String apiUrl = 'https://magic-sign.cloud/v_ar/web/api/displaygroup';

  
      String? accessToken = await getAccessToken();
      if (accessToken == null) {
        Get.snackbar(
          "Error",
          "Access token not available. Please log in again.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return []; 
      }
  try {
      http.Response response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      print('Response Status Code: ${response.statusCode}');
      print('Response Bodyyyyyyyyyyyyyyyyyyyyyyyy: ${response.body}');
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body) as List;

        List<DisplayGroup> displayGroups = jsonData.map((data) => DisplayGroup.fromJson(data)).toList();
        jsonData.forEach((display) {
          int? displayGroupId = display['id'];
          String? name = display['name'];

         /* if (displayGroupId != null && name != null) {
            DisplayGroup newDisplayGroup = DisplayGroup(
              id: displayGroupId,
              name: name,
            );
            displayGroups.add(newDisplayGroup);
          }*/
        });

        print('Display Groups: $displayGroups');

        displayGroupList.assignAll(displayGroups);
        return displayGroups;
      } else {
        print('Errorrr: ${response.statusCode}');
        return []; 
      }
    } catch (e) {
      print('Errorrrr: $e');
      return []; 
    }
  }
  Future<List<Player>> fetchPlayers() async {
  String apiUrl = 'https://magic-sign.cloud/v_ar/web/api/display-ms';

  try {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      Get.snackbar(
        "Error",
        "Access token not available. Please log in again.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return []; 
    }

    http.Response response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body) as List;
      
      List<Player> players = jsonData.map((data) => Player.fromJson(data)).toList();
       jsonData.forEach((player) {
          int? playerId = player['id'];
          String? name = player['display'];
        });
      playerList.assignAll(players);
      print('Players: $players');

      return players;


    } else {
      print('Error: ${response.statusCode}');
      return []; 
    }
  } catch (e) {
    print('Error: $e');
    return []; 
  }
}

}
