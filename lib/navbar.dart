import 'package:flutter/material.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/dashboard.dart';
import 'package:magic_sign_mobile/screens/drawer_item.dart';
import 'package:magic_sign_mobile/screens/media_screen/media_screen.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

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
            const SizedBox(height: 20,),
              const Divider(thickness: 1, height: 10, color: Colors.grey,),
              
            DrawerItem(
              name: 'Tableau de bord',
              icon: Icons.dashboard,
              onPressed: () => onItemPressed(context, index: 0),
            ),
           const SizedBox(height: 20,),
            DrawerItem(
              name: 'Médiathèque',
              icon: Icons.mediation_sharp,
              onPressed: () => onItemPressed(context, index: 0),
            ),
            const SizedBox(height: 20,),

            DrawerItem(
              name: 'Playlists',
              icon: Icons.dashboard,
              onPressed: () => onItemPressed(context, index: 0),
            ),
            const SizedBox(height: 20,),

            DrawerItem(
              name: 'Afficheurs',
              icon: Icons.dashboard,
              onPressed: () => onItemPressed(context, index: 0),
            ),
            const SizedBox(height: 20,),

            DrawerItem(
              name: 'Planification',
              icon: Icons.dashboard,
              onPressed: () => onItemPressed(context, index: 0),
            ),
            //some space
            const Expanded(child: SizedBox()),
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
                    onPressed: () => onItemPressed(context, index: 0),
                  ),
                  //GO TO SETTINGS
                  DrawerItem(
                    name: 'Paramétres',
                    icon: Icons.settings,
                    onPressed: () => onItemPressed(context, index: 0),
                  ),

                  const Divider(),

                  //LOGOUT
                  DrawerItem(
                    name: 'Se déconnecter',
                    icon: Icons.logout,
                    onPressed: () => onItemPressed(context, index: 0),
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
    switch (index) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MediaScreen()));
      case 1 :
      Navigator.push(context, 
      MaterialPageRoute(builder: (context) => const MediaScreen()));
      
        break;
      default:
        Navigator.pop(context);
        break;
    }
  }
}
