import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/Theme/ThemeService.dart';
import 'package:magic_sign_mobile/controller/ThemeController.dart';
import 'package:magic_sign_mobile/widgets/BaseScreen.dart';

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
    return BaseScreen(
      title: 'Paramètre',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => SwitchListTile(
                title: Text(
                  'Dark Mode',
                  style: TextStyle(fontSize: 17),
                ),
                value: themeController.isDarkMode.value,
                onChanged: (value) {
                  themeController.toggleTheme();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
