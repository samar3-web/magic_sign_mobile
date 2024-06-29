import 'dart:convert';

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

  List<Map<String, dynamic>> templates = [];
  List<String> templateImages = [
    //midldle zone
    'https://magic-sign.cloud//v_ar/web/theme/default/img/template/h1.png',

    //2r
    'https://magic-sign.cloud//v_ar/web/theme/default/img/template/h2.png',

    //middle vertical
    'https://magic-sign.cloud//v_ar/web/theme/default/img/template/h3.png',

//v1
    'https://magic-sign.cloud//v_ar/web/theme/default/img/template/v1.png',

//v2
    'https://magic-sign.cloud//v_ar/web/theme/default/img/template/v2.png',
//v3

    'https://magic-sign.cloud//v_ar/web/theme/default/img/template/v3.png',

    'https://magic-sign.cloud//v_ar/web/theme/default/img/template/theme-full.png',
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
        List<dynamic> responseData = json.decode(response.body);
        setState(() {
          templates = responseData.asMap().entries.map((entry) {
            int index = entry.key;
            var template = entry.value;
            return {
              "layoutId": template["layoutId"],
              "image": templateImages[index %
                  templateImages
                      .length] 
            };
          }).toList();
        });
        print('get template successfully');
      } else {
        print('Failed to get template. Status code: ${response.statusCode}');
        throw Exception('Failed to get template');
      }
    } catch (e) {
      print('Error get template: $e');
    }
  }

  int? selectedLayoutId;

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
            Text('Choisir un modèle'),
            SizedBox(height: 8.0),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedLayoutId = templates[index]["layoutId"];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedLayoutId == templates[index]["layoutId"]
                            ? Colors.blue
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Image.network(
                      templates[index]["image"],
                      fit: BoxFit.fill,
                    ),
                  ),
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
            String name = nameController.text.trim();
            String description = descriptionController.text.trim();
            if (name.isEmpty) {
               Get.snackbar('Erreur', 'Veuillez remplir le nom',
                  backgroundColor: Colors.red);
            } else if (playlistController.isNameExist(name)) {
              Get.snackbar('Erreur', 'Le nom existe déjà',
                  backgroundColor: Colors.red);
            } else {
              playlistController.addLayout(
                name: name,
                description: description,
                layoutId: selectedLayoutId,
              );
              Navigator.of(context).pop();
            }
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
