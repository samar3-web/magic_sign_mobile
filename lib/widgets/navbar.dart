import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/widgets/drawer_item.dart';
import 'package:magic_sign_mobile/screens/home_screen/home_screen.dart';
import 'package:magic_sign_mobile/controller/loginController.dart';
import 'package:magic_sign_mobile/screens/media_screen/media_screen.dart';
import 'package:magic_sign_mobile/screens/my_profile/my_profile.dart';
import 'package:magic_sign_mobile/screens/planification/planification_screen.dart';
import 'package:magic_sign_mobile/screens/player/player_screen.dart';
import 'package:magic_sign_mobile/screens/playlist/playlist_screen.dart';

class NavBar extends StatefulWidget {
  NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final LoginController _loginController = LoginController();

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Oui'),
              onPressed: () {
                Navigator.of(context).pop();
                _loginController.logout();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: boxColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 80, 24, 0),
          child: Column(
            children: [
              Image.asset(
                'assets/images/big-logo.png',
                height: 150.0,
                width: 150.0,
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                thickness: 1,
                height: 10,
                color: Colors.grey,
              ),
              Flexible(
                child: ListView.builder(
                  itemCount: drawerRoutes.length,
                  itemBuilder: (context, index) {
                    final item = drawerRoutes[index];
                    return Column(
                      children: [
                        DrawerItem(
                          name: item['name'],
                          icon: item['icon'],
                          onPressed: () => onItemPressed(context, index: index),
                        ),
                        if (index != drawerRoutes.length - 1)
                          const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
              ),
              //some space
              const SizedBox(
                height: 15,
              ),
              //---------------------------PROFILE, SETTINGS & LOGOUT BUTTONS---------------------------
              Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  children: [
                    //HORIZONTAL LINE
                    const Divider(),

                    //GO TO PROFILE
                    DrawerItem(
                      name: 'Mon profil',
                      icon: Icons.account_circle,
                      onPressed: () => onItemPressed(context, index: -1),
                    ),
                    //GO TO SETTINGS (Placeholder)
                    DrawerItem(
                      name: 'Paramètres',
                      icon: Icons.settings,
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed('/settings'),
                    ),

                    const Divider(),

                    //LOGOUT
                    DrawerItem(
                      name: 'Se déconnecter',
                      icon: Icons.logout,
                      onPressed: () => _showLogoutConfirmationDialog(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onItemPressed(BuildContext context, {required int index}) {
    Navigator.pop(context);
    if (index >= 0 && index < drawerRoutes.length) {
      final String routeName = drawerRoutes[index]['routeName'];
      Navigator.pushNamed(context, routeName);
    } else if (index == -1) {
      Navigator.pushNamed(context, MyProfile.routeName);
    }
  }
}

final List<Map<String, dynamic>> drawerRoutes = [
  {
    'name': 'Tableau de bord',
    'icon': Icons.dashboard,
    'routeName': HomeScreen.routeName
  },
  {
    'name': 'Médiathèque',
    'icon': Icons.ondemand_video,
    'routeName': MediaScreen.routeName
  },
  {
    'name': 'Playlists',
    'icon': Icons.playlist_play,
    'routeName': PlaylistScreen.routeName
  },
  {'name': 'Afficheurs', 'icon': Icons.tv, 'routeName': PlayerScreen.routeName},
  {
    'name': 'Planification',
    'icon': Icons.event,
    'routeName': PlanificationScreen.routeName
  },
];
