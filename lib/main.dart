import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/ThemeController.dart';
import 'package:magic_sign_mobile/routes.dart';
import 'package:magic_sign_mobile/screens/splash_screen.dart';

void main() async {
  await GetStorage.init();

  runApp(HomeScreen());
}

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);
  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
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
              backgroundColor:
                  MaterialStateProperty.all<Color>(kSecondaryColor),
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
              foregroundColor:
                  MaterialStateProperty.all<Color>(kSecondaryColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: kDarkBackgroundColor,
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
                    bodyLarge: TextStyle(
                      color: kTextWhiteColor,
                      fontSize: 35.0,
                      fontWeight: FontWeight.bold,
                    ),
                    titleSmall: TextStyle(
                      color: kTextWhiteColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle:
                TextStyle(fontSize: 15.0, color: kTextWhiteColor, height: 0.5),
            hintStyle:
                TextStyle(fontSize: 16.0, color: kTextWhiteColor, height: 0.5),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: kTextWhiteColor, width: 0.7),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: kTextDarkColor),
            ),
            disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: kTextDarkColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: kPrimaryColor),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: kErrorBorderColor, width: 1.2),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: kErrorBorderColor, width: 1.2),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(kSecondaryColor),
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
              foregroundColor:
                  MaterialStateProperty.all<Color>(kSecondaryColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        themeMode:
            themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        initialRoute: splashScreen.routeName,
        routes: routes,
      ),
    );
  }
}
