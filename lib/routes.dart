
import 'package:flutter/material.dart';
import 'package:magic_sign_mobile/screens/splash_screen.dart';
import 'package:magic_sign_mobile/screens/login_screen/login_screen.dart';

Map<String, WidgetBuilder> routes = {
  splashScreen.routeName: (context) => const splashScreen(),
  LoginScreen.routeName: (context) => const LoginScreen(),
};
