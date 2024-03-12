import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/routes.dart';
import 'package:magic_sign_mobile/screens/splash_screen.dart';

void main() {
  runApp(const HomeScreen());
}

class HomeScreen extends StatelessWidget {
  
  const HomeScreen({Key? key}) : super(key: key);

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
        textTheme: GoogleFonts.sourceCodeProTextTheme(Theme.of(context).textTheme).apply().copyWith(
          // custom text for bodyText1
          bodyText1: TextStyle(
            color: boxColor,
            fontSize: 35.0,
            fontWeight: FontWeight.bold,
          ),
          subtitle2: TextStyle(
            color: boxColor,
            fontSize: 18.0,
            fontWeight: FontWeight.w300,
          ),
        
        ),
        inputDecorationTheme: InputDecorationTheme(
          //label style for formfield
                              labelStyle: TextStyle(
                                  fontSize: 15.0,
                                  color: kTextWhiteColor,
                                  height: 0.5),
                              //hint style
                              hintStyle: TextStyle(
                                  fontSize: 16.0,
                                  color: kTextWhiteColor,
                                  height: 0.5),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: kTextWhiteColor, width: 0.7
                                      ),
                                       ),
                                       border: UnderlineInputBorder(
                                        borderSide:BorderSide(
                                          color: kTextLightColor
                                        ),
                                         ),
                                         disabledBorder: UnderlineInputBorder(
                                        borderSide:BorderSide(
                                          color: kTextLightColor
                                        ),
                                         ),
                                         focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color:kPrimaryColor,
                                          
                                            ),
                                         ),
                                         errorBorder:  UnderlineInputBorder(
                                        borderSide:BorderSide(
                                          color: kErrorBorderColor,
                                          width: 1.2
                                        ),
                                         ),
                                         focusedErrorBorder: UnderlineInputBorder(
                                        borderSide:BorderSide(
                                          color: kErrorBorderColor,
                                          width: 1.2,
                                        ),
                                         ),
        )
      ),

      // initial route is splash screen
      initialRoute: splashScreen.routeName,
      routes: routes,
    );
  }
}
