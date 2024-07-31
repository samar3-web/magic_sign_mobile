import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/Theme/ThemeService.dart';
import 'package:magic_sign_mobile/controller/ThemeController.dart';
import 'package:magic_sign_mobile/controller/loginController.dart';
import 'package:magic_sign_mobile/screens/preLogin_screen/PreLoginScreen.dart';
import 'package:magic_sign_mobile/widgets/BaseScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  static String routeName = '/settings';
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeController themeController = Get.find();
  final LoginController loginController = Get.find();

  String serverUrl = '';

  @override
  void initState() {
    super.initState();
    _loadServerUrl();
  }

  Future<void> _loadServerUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      serverUrl = prefs.getString('base_url') ?? 'Aucun serveur configuré';
    });
  }

  Future<void> _changeServer() async {
    await loginController.clearApiConfiguration();

    Get.to(Preloginscreen());
  }

  void _connectToServer() {
    // Ajoutez ici votre logique pour se connecter au serveur actuel
    // Par exemple, vous pouvez appeler une méthode de connexion dans votre contrôleur
    Get.snackbar('Connecté', 'Connexion au serveur $serverUrl réussie');
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Paramètres',
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
            SizedBox(height: 20),
            Text(
              'Serveur actuel:',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              serverUrl,
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 20),
            Wrap(
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.swap_horiz),
                  label: Text('Changer de serveur'),
                  onPressed: _changeServer,
                ),
                /*ElevatedButton.icon(
                  icon: Icon(Icons.cloud_done),
                  label: Text('Se connecter'),
                  onPressed: _connectToServer,
                ),*/
              ],
            ),
          ],
        ),
      ),
    );
  }
}
