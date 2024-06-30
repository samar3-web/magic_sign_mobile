import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/ThemeController.dart';
import 'package:magic_sign_mobile/routes.dart';
import 'package:magic_sign_mobile/screens/splash_screen.dart';

void main() {
  runApp( HomeScreen());
}

class HomeScreen extends StatelessWidget {
   HomeScreen({Key? key}) : super(key: key);
    final ThemeController themeController = Get.put(ThemeController());


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Magic Sign Mobile',
      theme: ThemeData.light().copyWith(
        // scaffold default color
        scaffoldBackgroundColor: kPrimaryColor,
        primaryColor: kPrimaryColor,
        appBarTheme: AppBarTheme(
          color: boxColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme:
            GoogleFonts.sourceCodeProTextTheme(Theme.of(context).textTheme)
                .apply()
                .copyWith(
                  // custom text for bodyText1
                  bodyLarge: TextStyle(
                    color: boxColor,
                    fontSize: 35.0,
                    fontWeight: FontWeight.bold,
                  ),
                  titleSmall: TextStyle(
                    color: boxColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
        inputDecorationTheme: InputDecorationTheme(
          //label style for formfield
          labelStyle:
              TextStyle(fontSize: 15.0, color: kTextWhiteColor, height: 0.5),
          //hint style
          hintStyle:
              TextStyle(fontSize: 16.0, color: kTextWhiteColor, height: 0.5),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kTextWhiteColor, width: 0.7),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: kTextLightColor),
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kTextLightColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: kPrimaryColor,
            ),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kErrorBorderColor, width: 1.2),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: kErrorBorderColor,
              width: 1.2,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(kSecondaryColor),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(kSecondaryColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
        darkTheme: ThemeData.dark(),
        themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      // initial route is splash screen
      initialRoute: splashScreen.routeName,
      routes: routes,
    );
  }
}
