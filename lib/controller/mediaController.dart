import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:magic_sign_mobile/screens/home_screen/home_screen.dart';
import 'package:magic_sign_mobile/model/Media.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MediaController extends GetxController {
  final String apiUrl = "https://magic-sign.cloud/v_ar/web/api/library";

  var isLoading = false.obs;
  var mediaList = <Media>[].obs;
  var originalMediaList = <Media>[].obs;
  var currentPage = 0.obs;
  final int pageSize = 20;

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    print('Access Token stored  ***********: $accessToken');
    return accessToken;
  }

  @override
  void onInit() {
    super.onInit();
    getMedia();
  }

  Future<void> getMedia({int start = 0, int length = 20}) async {
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

        print("Media fetched and lists updated.");
      } else {
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
    } finally {
      isLoading(false);
    }
  }

  void loadMoreMedia() {
    if (!isLoading.value) {
      currentPage.value += 1;
      getMedia(start: currentPage.value * pageSize, length: pageSize);
    }
  }

  Future<String> getImageUrl(String storedAs) async {
    String? accessToken = await getAccessToken();

    final response = await http.get(
      Uri.parse('https://magic-sign.cloud/v_ar/web/MSlibrary/$storedAs'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    print("Response Status Code: ${response.statusCode}");
    if (response.statusCode == 200) {
      // Convert the response body from bytes to base64 string
      Uint8List bytes = response.bodyBytes;
      String base64String = base64Encode(bytes);
      return base64String;
    } else {
      throw Exception('Failed to load image URL: ${response.statusCode}');
    }
  }

  Future<void> uploadFiles(BuildContext context, List<File> files) async {
    const int maxFileSize = 100 * 1024 * 1024;
    try {
      String? accessToken = await getAccessToken();

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
          print('File uploaded successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
          await Future.delayed(Duration(seconds: 5));
          await getMedia();
        } else {
          print('File upload failed');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('File upload failed'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      print('Error uploading files: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('File upload failed'),
        backgroundColor: Colors.red,
      ));
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

  deleteMedia(int mediaId) async {
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
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('deleted');
        Get.snackbar('Supression', ' Le média a été supprimé.',
            backgroundColor: Colors.green);
      } else {
        print('response status code not 200');
      }
      return true;
    } catch (e) {
      print(e);
      return false;
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
        originalMediaList.assignAll(jsonData);
      } else {
        print('Failed to search media. Status code: ${response.statusCode}');
        Get.snackbar(
          "Error",
          "Failed to search media. Status code: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error searching media: $e');
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
}
