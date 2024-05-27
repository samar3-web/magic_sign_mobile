import 'package:flutter/material.dart';
import 'package:magic_sign_mobile/model/Player.dart';
import 'package:magic_sign_mobile/model/Timeline.dart';
import 'package:magic_sign_mobile/screens/home_screen/home_screen.dart';
import 'package:magic_sign_mobile/screens/media_screen/media_screen.dart';
import 'package:magic_sign_mobile/model/Playlist.dart';
import 'package:magic_sign_mobile/screens/my_profile/my_profile.dart';
import 'package:magic_sign_mobile/screens/planification/planification_screen.dart';
import 'package:magic_sign_mobile/screens/player/player_group.dart';
import 'package:magic_sign_mobile/screens/player/player_screen.dart';
import 'package:magic_sign_mobile/screens/playlist/playlist_details.dart';
import 'package:magic_sign_mobile/screens/playlist/playlist_screen.dart';
import 'package:magic_sign_mobile/screens/playlist/previewScreen.dart';
import 'package:magic_sign_mobile/screens/splash_screen.dart';
import 'package:magic_sign_mobile/screens/login_screen/login_screen.dart';

Map<String, WidgetBuilder> routes = {
  splashScreen.routeName: (context) => const splashScreen(),
  LoginScreen.routeName: (context) => const LoginScreen(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  MyProfile.routeName: (context) => const MyProfile(),
  MediaScreen.routeName: (context) => const MediaScreen(),
  PlaylistScreen.routeName: (context) => const PlaylistScreen(),
  PlanificationScreen.routeName: (context) => const PlanificationScreen(),
  PlayerGroup.routeName: (context) => const PlayerGroup(),
  PlayerScreen.routeName: (context) => const PlayerScreen(),
  PlaylistDetail.routeName: (BuildContext context) => (PlaylistDetail(
        playlist: ModalRoute.of(context)!.settings.arguments as Playlist,
      )),
  PreviewScreen.routeName: (BuildContext context) => (PlaylistDetail(
        playlist: ModalRoute.of(context)!.settings.arguments as Playlist,
      )),
};
