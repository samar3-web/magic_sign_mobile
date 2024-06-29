import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:magic_sign_mobile/controller/connectionController.dart';
import 'package:magic_sign_mobile/controller/loginController.dart';
import 'package:magic_sign_mobile/screens/home_screen/home_screen.dart';
import 'package:magic_sign_mobile/model/Media.dart';
import 'package:magic_sign_mobile/screens/media_screen/media_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sqlitedb/magic_sign_db.dart';

class MediaController extends GetxController {
  final String apiUrl = "https://magic-sign.cloud/v_ar/web/api/library";
  var isConnected = false;
  var isLoading = false.obs;
  var mediaList = <Media>[].obs;
  var originalMediaList = <Media>[].obs;
  var currentPage = 0.obs;
  final int pageSize = 20;

  var isUpdating = false.obs;
  TextEditingController name = TextEditingController();
  TextEditingController duration = TextEditingController();
  LoginController loginController = Get.put(LoginController());

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    print('Access Token stored  ***********: $accessToken');
    return accessToken;
  }

  @override
  void onInit() {
    super.onInit();
    syncMedias();
    getMedia();
  }

  Future<List<Media>> getMedia({int start = 0, int length = 200}) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      try {
        isLoading.value = true;
        String? accessToken = await getAccessToken();
        if (accessToken == null) {
          await loginController.refreshAccessToken();
          accessToken = await getAccessToken();
          isLoading.value = false;
        }

        final response = await http.get(
          Uri.parse('$apiUrl?start=$start&length=$length'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'Cache-Control': 'no-cache',
          },
        );

        if (response.statusCode == 200) {
          var jsonData = (json.decode(response.body) as List)
              .map((e) => Media.fromJson(e))
              .toList();
          jsonData.sort((a, b) => b.createdDt.compareTo(a.createdDt));

          if (start == 0) {
            mediaList.assignAll(jsonData);
            originalMediaList.assignAll(jsonData);
          } else {
            mediaList.addAll(jsonData);
            originalMediaList.addAll(jsonData);
          }
          for (var media in mediaList) {
            await MagicSignDB().createMedia(media, 1);
          }
          print('olllllllllld get ');
          print(mediaList.length);
          print("Media fetched and lists updated.");
          isLoading.value = false;
          return parseMediaItems(response.body);
        } else {
          isLoading.value = false;

          print('Failed to load media. Status code: ${response.statusCode}');
          Get.snackbar(
            "Error",
            "Failed to load media. Status code: ${response.statusCode}",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        print('Error fetching media: $e');
        Get.snackbar(
          "Error",
          "Error fetching media. Please try again later.",
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar("offline mode", "you are now in the offline mode ");
      var players = await MagicSignDB().fetchAllMedia();
      mediaList.value = players;
    }
    return [];
  }

  Future<String> getImageUrl(String storedAs) async {
    String? accessToken = await getAccessToken();

    final response = await http.get(
      Uri.parse('https://magic-sign.cloud/v_ar/web/MSlibrary/$storedAs'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      Uint8List bytes = response.bodyBytes;
      String base64String = base64Encode(bytes);
      return base64String;
    } else {
      throw Exception('Failed to load image URL: ${response.statusCode}');
    }
  }

  Future<void> showProgressDialog(
      BuildContext context, ValueNotifier<double> progressNotifier) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: ValueListenableBuilder<double>(
            valueListenable: progressNotifier,
            builder: (context, progress, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Uploading... ${progress.toStringAsFixed(0)}%'),
                  SizedBox(height: 20),
                  LinearProgressIndicator(value: progress / 100),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> uploadFiles(BuildContext context, List<File> files) async {
    const int maxFileSize = 100 * 1024 * 1024;
    var isConnected = await Connectioncontroller.isConnected();
    if (isConnected) {
      ValueNotifier<double> progressNotifier = ValueNotifier<double>(0);

      try {
        String? accessToken = await getAccessToken();
        int totalFiles = files.length;
        int uploadedFiles = 0;

        showProgressDialog(context, progressNotifier);

        for (File file in files) {
          if (await file.length() > maxFileSize) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File ${file.path} exceeds 100 MB size limit.'),
                backgroundColor: Colors.red,
              ),
            );
            continue;
          }

          var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

          request.files.add(
            await http.MultipartFile.fromPath('files', file.path),
          );
          request.headers['Authorization'] = 'Bearer $accessToken';

          var response = await request.send();

          if (response.statusCode == 200) {
            uploadedFiles++;
            print('File uploaded successfully');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File uploaded successfully'),
                backgroundColor: Colors.green,
              ),
            );
            await Future.delayed(Duration(seconds: 1));
            await getMedia();
          } else {
            print('File upload failed');
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('File upload failed'),
              backgroundColor: Colors.red,
            ));
          }
          progressNotifier.value = (uploadedFiles / totalFiles) * 100;
        }
      } catch (e) {
        print('Error uploading files: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('File upload failed'),
          backgroundColor: Colors.red,
        ));
      } finally {
        Navigator.of(context).pop();
      }
    } else {
      for (var file in files) {
        print(file.path);
        if (await file.length() < maxFileSize) {
          Media media = new Media(
            Random().nextInt(1000),
            9,
            file.path,
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
          );
          await MagicSignDB().createMedia(media, 0);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File ${file.path} exceeds 100 MB size limit.'),
              backgroundColor: Colors.red,
            ),
          );
          continue;
        }
        getMedia();
      }
    }
  }

  updateMediaData(
      int mediaId, String name, String duration, String retired) async {
    try {
      Map<String, dynamic> body = {
        'name': name,
        'duration': duration.toString(),
        'retired': retired.toString(),
      };
      String? accessToken = await getAccessToken();

      http.Response response = await http.put(
        Uri.parse('https://magic-sign.cloud/v_ar/web/api/library/$mediaId'),
        body: body,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar('Modification', ' Le média a été modifié.');
        Get.to(const MediaScreen());
        getMedia();
      } else {}
    } catch (e) {
      print(e);
    }
  }

  deleteMedia(int mediaId) async {
    var isConnected = await Connectioncontroller.isConnected();
    if (isConnected) {
      try {
        Map<String, dynamic> body = {'forceDelete': '1'};
        String? accessToken = await getAccessToken();
        http.Response response = await http.delete(
          Uri.parse('https://magic-sign.cloud/v_ar/web/api/library/$mediaId'),
          body: body,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        );

        if (response.statusCode == 204) {
        
        } else {
          print('response status code not 204');
        }
        return true;
      } catch (e) {
        return false;
      }
    } else {
      await MagicSignDB().deleteMedia(mediaId);
      getMedia();
      Get.to(const MediaScreen());
    }
  }

  //search
  Future<void> searchMedia(String value) async {
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
        Uri.parse('$apiUrl?media=$value'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = (json.decode(response.body) as List)
            .map((e) => Media.fromJson(e))
            .toList();

        print(jsonData);
        mediaList.assignAll(jsonData);
      } else {
        Get.snackbar(
          "Error",
          "Failed to search media. Status code: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Error searching media. Please try again later.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  //filter


  void filterByType(String type) {
    String lowercaseType = type.toLowerCase();
    var filteredMediaList = originalMediaList
        .where((media) => media.mediaType.toLowerCase() == lowercaseType)
        .toList();
    mediaList.assignAll(filteredMediaList);
  }

  void filterByOwner(String owner) {
    String lowercaseOwner = owner.toLowerCase();
    var filteredMediaList = originalMediaList
        .where((media) => media.owner.toLowerCase() == lowercaseOwner)
        .toList();
    mediaList.assignAll(filteredMediaList);
  }

  Media? getMediaById(int mediaId) {
    for (var media in mediaList) {
      if (media.mediaId == mediaId) {
        return media;
      }
    }
    return null;
  }

  void syncMedias() async {
    var isConnected = await Connectioncontroller.isConnected();
    if (isConnected) {
      var unsyncedMedias = await MagicSignDB().SYNCfetchAllMedia();
      if (unsyncedMedias.isNotEmpty) {
        for (var media in unsyncedMedias) {
          print("syncronizing files ");
          File file = new File(media.name);
          await uploadFiles(Get.context!, [file]);
          MagicSignDB().deleteMedia(media.mediaId);
        }
      }
      getMedia();
    }
  }
}
