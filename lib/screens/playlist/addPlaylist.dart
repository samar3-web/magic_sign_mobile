import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/playlistController.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddLayoutPopup extends StatefulWidget {
  @override
  _AddLayoutPopupState createState() => _AddLayoutPopupState();
}

class _AddLayoutPopupState extends State<AddLayoutPopup> {
  final PlaylistController playlistController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<String> templateImages = [
    // Add your image URLs here for each template
    'https://magic-sign.cloud//v_ar/web/theme/default/img/template/theme-full.png',
    'https://magic-sign.cloud//v_ar/web/theme/default/img/template/h1.png',
    'https://magic-sign.cloud//v_ar/web/theme/default/img/template/h2.png',
    'https://magic-sign.cloud//v_ar/web/theme/default/img/template/h3.png',
    'https://magic-sign.cloud//v_ar/web/theme/default/img/template/v1.png',
    'https://magic-sign.cloud//v_ar/web/theme/default/img/template/v2.png',
    'https://magic-sign.cloud//v_ar/web/theme/default/img/template/v3.png',
  ];

  @override
  void initState() {
    super.initState();
    getTemplate();
  }

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    print('Access Token stored  *********: $accessToken');
    return accessToken;
  }

  Future<void> getTemplate() async {
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
        // Handle your template data here
      } else {
        print('Failed to get template. Status code: ${response.statusCode}');
        throw Exception('Failed to get template');
      }
    } catch (e) {
      print('Error get template: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Ajouter une playlist',
        style: TextStyle(
          fontSize: 17.0,
          fontWeight: FontWeight.w300,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.w300,
              ),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: kTextBlackColor, fontSize: 14.0),
              ),
            ),
            TextField(
              controller: descriptionController,
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.w300,
              ),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: kTextBlackColor, fontSize: 14.0),
              ),
            ),
            SizedBox(height: 8.0),
            Text('choisir un modèle'),
            SizedBox(height: 8.0),

            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: 4, // Number of images in the first row
              itemBuilder: (context, index) {
                return Image.network(
                  templateImages[index],
                  fit: BoxFit.fill,
                );
              },
            ),
            SizedBox(height: 8.0),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Image.network(
                  templateImages[index + 4],
                  fit: BoxFit.fill,
                );
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            String name = nameController.text;
            String description = descriptionController.text;
            playlistController.addLayout(
              name: name,
              description: description,
            );
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kSecondaryColor,
          ),
          child: Text(
            'Enregistrer',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
