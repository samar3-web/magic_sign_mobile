import 'dart:convert';

import 'package:get/get.dart';
import 'package:magic_sign_mobile/model/DisplayGroup.dart';
import 'package:magic_sign_mobile/model/Player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PlayerController extends GetxController {
  var playerList = <Player>[].obs;
  var displayGroupList = <DisplayGroup>[].obs;
  String apiUrl = 'https://magic-sign.cloud/v_ar/web/api/displaygroup';

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    print('Access Token stored  ***********: $accessToken');
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
        var jsonDataa = (json.decode(response.body) as List)
            .map((e) => Player.fromJson(e))
            .toList();

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

        List<DisplayGroup> displayGroups =
            jsonData.map((data) => DisplayGroup.fromJson(data)).toList();
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

        List<Player> players =
            jsonData.map((data) => Player.fromJson(data)).toList();
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

  Future<void> authorizePlayer(int displayId) async {
    final url =
        'https://magic-sign.cloud/v_ar/web/api/display-ms/authorise/$displayId';
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      Get.snackbar(
        "Error",
        "Access token not available. Please log in again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      print('Authorization response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        print('Success : Display authorized successfully');
      } else {
        print('Error :  Failed to authorize display');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  Future<void> setDefaultLayout(int displayId, int layoutId) async {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      Get.snackbar(
        "Error",
        "Access token not available. Please log in again.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final String apiUrl =
        "https://magic-sign.cloud/v_ar/web/api/display-ms/defaultlayout/$displayId";

    try {
      Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      Map<String, String> requestBody = {
        "layoutId": layoutId.toString(),
      };

      print(
          "Sending PUT request to $apiUrl with headers $headers and body $requestBody");
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: headers,
        body: requestBody,
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        print("Default layout set successfully.");
      } else if (response.statusCode == 404) {
        print("Resource not found. Status code: 404");
        Get.snackbar("Error",
            "Ressource non trouvée (404). Veuillez vérifier les identifiants.");
      } else {
        print(
            "Failed to set default layout. Status code: ${response.statusCode}");
        Get.snackbar("Error",
            "Échec de la définition de la mise en page par défaut. Code de statut: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      Get.snackbar("Error", "Une erreur s'est produite: $e");
    }
  }

  addDisplayGroup({required String displayGroup, int? isDynamic}) async {
    try {
      String? accessToken = await getAccessToken();
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'displayGroup': displayGroup,
          'isDynamic': isDynamic.toString(),
        },
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
      );

      if (response.statusCode == 201) {
        print(response.body);
        print('group added successfully');
      } else {
        // Handle error response
        print('Failed to add group. Status code: ${response.statusCode}');
                print(response.body);

        throw Exception('Failed to add group');
      }
    } catch (e) {
      // Handle exceptions
      print('Error adding group: $e');
    }
  }
}
