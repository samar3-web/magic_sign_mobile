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

  List<String> serverUrls = [];
  String? activeServerUrl;

  @override
  void initState() {
    super.initState();
    _loadServerUrls();
  }

  Future<void> _loadServerUrls() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      serverUrls = prefs.getStringList('base_url') ?? [];
      activeServerUrl = prefs.getString('active_server_url') ??
          (serverUrls.isNotEmpty
              ? serverUrls.first
              : 'Aucun serveur configuré');
    });
    // Print the length of the stored base URL list
    print('Length of stored base URL list: ${serverUrls.length}');
  }

  Future<void> _addServer() async {
    await loginController.clearApiConfiguration();
    // Navigate to the PreLoginScreen to add a new server
    await Get.to(() => Preloginscreen());
    // After returning, update the server list
    await _loadServerUrls();
  }

  Future<void> _saveActiveServerUrl(String? url) async {
    if (url == null || url.isEmpty) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_server_url', url);
    setState(() {
      activeServerUrl = url;
    });
  }

  void _connectToServer() {
    if (activeServerUrl != null && activeServerUrl!.isNotEmpty) {
      Get.snackbar('Connecté', 'Connexion au serveur $activeServerUrl réussie');
    } else {
      Get.snackbar('Erreur', 'Aucun serveur configuré');
    }
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
              activeServerUrl ?? 'Aucun serveur configuré',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Ajouter serveur'),
                  onPressed: _addServer,
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.cloud_done),
                  label: Text('Se connecter'),
                  onPressed: _connectToServer,
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: serverUrls.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      serverUrls[index],
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    trailing: activeServerUrl == serverUrls[index]
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () async {
                      await _saveActiveServerUrl(serverUrls[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
