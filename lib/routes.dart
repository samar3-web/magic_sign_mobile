
import 'package:flutter/material.dart';
import 'package:magic_sign_mobile/screens/home_screen/home_screen.dart';
import 'package:magic_sign_mobile/screens/media_screen/media_screen.dart';
import 'package:magic_sign_mobile/screens/my_profile/my_profile.dart';
import 'package:magic_sign_mobile/screens/planification/planification_screen.dart';
import 'package:magic_sign_mobile/screens/player/player_screen.dart';
import 'package:magic_sign_mobile/screens/playlist/playlist_screen.dart';
import 'package:magic_sign_mobile/screens/splash_screen.dart';
import 'package:magic_sign_mobile/screens/login_screen/login_screen.dart';

Map<String, WidgetBuilder> routes = {
  splashScreen.routeName: (context) => const splashScreen(),
  LoginScreen.routeName: (context) => const LoginScreen(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  MyProfile.routeName: (context) => const MyProfile(),
  MediaScreen.routeName: (context) => const MediaScreen(),
  PlaylistScreen.routeName: (context) => const PlaylistScreen(),
  PlayerScreen.routeName:(context) => const PlayerScreen(),
  PlanificationScreen.routeName:(context) => const PlanificationScreen(),

};


