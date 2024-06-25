import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/controller/connectionController.dart';
import 'package:magic_sign_mobile/controller/loginController.dart';
import 'package:magic_sign_mobile/model/DisplayGroup.dart';
import 'package:magic_sign_mobile/model/Player.dart';
import 'package:magic_sign_mobile/sqlitedb/magic_sign_db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PlayerController extends GetxController {
  var playerList = <Player>[].obs;
  var displayGroupList = <DisplayGroup>[].obs;
  String apiUrl = 'https://magic-sign.cloud/v_ar/web/api/displaygroup';
  var selectedPlaylist = ''.obs;
  LoginController loginController = Get.put(LoginController());

  @override
  void onInit() {
    fetchData();
  }

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    print('Access Token stored  ***********: $accessToken');
    return accessToken;
  }

  fetchData() async {
    String apiUrl = 'https://magic-sign.cloud/v_ar/web/api/display-ms';
    var isConnected = await Connectioncontroller.isConnected();
    if (isConnected) {
      try {
        String? accessToken = await getAccessToken();
        if (accessToken == null) {
          await loginController.refreshAccessToken();
          accessToken = await getAccessToken();
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
          for (Player player in playerList) {
            await MagicSignDB().createPlayer(player, 1);
          }
          return displayGroupIds;
        } else {
          print('Erreur: ${response.statusCode}');
          return [];
        }
      } catch (e) {
        print('Erreur: $e');
        return [];
      }
    } else {
      Get.snackbar("offline mode", "you are now in the offline mode ");

      var players = await MagicSignDB().fetchAllPlayers();
      playerList.value = players;
      return players;
    }
  }

  Future<List<Map<String, dynamic>>> fetch() async {
    String apiUrl = 'https://magic-sign.cloud/v_ar/web/api/display-ms';
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
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

        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body) as List<dynamic>;

          List<Map<String, dynamic>> displayGroupIds = [];
          jsonData.forEach((display) {
            int? displayGroupId = display['displayGroupId'];
            String? name = display['display'];
            int? isConnected = display['loggedIn'] == 1 ? 1 : 0;
            int? isAuthorized = display['licensed'] == 1 ? 1 : 0;

            if (displayGroupId != null && name != null) {
              Map<String, dynamic> newDisplay = {
                'id': displayGroupId,
                'name': name,
                'connected': isConnected,
                'authorized': isAuthorized,
              };
              displayGroupIds.add(newDisplay);
            }
          });

          return displayGroupIds;
        } else {
          print('Erreur: ${response.statusCode}');
          return [];
        }
      } catch (e) {
        print('Erreur: $e');
        return [];
      }
    } else {
      Get.snackbar("offline mode ", "you are now in the offline mode ");
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
    return playerList;
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
        fetchData();
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

  editPlayer({
    required int displayId,
    required String display,
    required int defaultLayoutId,
    required int licensed,
    required String license,
    required int incSchedule,
    required int emailAlert,
    required int wakeOnLanEnabled,
  }) async {
    try {
      Map<String, dynamic> body = {
        'display': display,
        'defaultLayoutId': defaultLayoutId.toString(),
        'licensed': licensed.toString(),
        'license': license,
        'incSchedule': incSchedule.toString(),
        'emailAlert': emailAlert.toString(),
        'wakeOnLanEnabled': wakeOnLanEnabled.toString(),
      };

      String? accessToken = await getAccessToken();
      http.Response response = await http.put(
        Uri.parse(
            'https://magic-sign.cloud/v_ar/web/api/display-ms/$displayId'),
        body: body,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        fetchData();
      } else {
        Get.snackbar("oops", response.body);
      }
    } catch (e) {
      Get.snackbar("oops", e.toString());
    }
  }

  Future<void> deletePlayer(int displayId) async {
    try {
      String? accessToken = await getAccessToken();
      http.Response response = await http.delete(
        Uri.parse(
            'https://magic-sign.cloud/v_ar/web/api/display-ms/$displayId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 204) {
        print('display deleted successfully');
        fetchData();
      } else {
        print('Failed to delete display');
      }
    } catch (e) {
      print(e);
    }
  }
}
