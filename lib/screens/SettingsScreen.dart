
import 'package:flutter/material.dart';
import 'package:get/get.dart' ;
import 'package:magic_sign_mobile/Theme/ThemeService.dart';
import 'package:magic_sign_mobile/controller/ThemeController.dart';


class SettingsScreen extends StatefulWidget {
  static String routeName = '/settings';
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeController themeController = Get.find();

  

  @override
  void initState() {
    super.initState();
    

  }
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Obx(() {
              return SwitchListTile(
                title: Text('Dark Mode'),
                value: themeController.isDarkMode.value,
                onChanged: (value) {
                  themeController.toggleTheme();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}