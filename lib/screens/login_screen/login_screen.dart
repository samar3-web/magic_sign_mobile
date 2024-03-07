import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/screens/home_screen/home_screen.dart'; // Import your home screen file

late bool _passwordVisible;

class LoginScreen extends StatefulWidget {
  static String routeName = 'LoginScreen';

  const LoginScreen({Key? key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _passwordVisible = true;
  }

  Future<void> _authenticateWithFingerprint() async {
    try {
      bool isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: 'Authenticate to login',
        useErrorDialogs: true,
        stickyAuth: true,
      );

      if (isAuthenticated) {
        // Navigate to the home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()), // Replace HomeScreen() with your actual home screen widget
        );
      }
    } catch (e) {
      // Handle authentication errors
      print('Authentication failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: ListView(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo_magic.png',
                    height: 150.0,
                    width: 150.0,
                  ),
                  SizedBox(
                    height: kDefaultPadding / 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hi ',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontWeight: FontWeight.w200),
                      ),
                      Text('Admin',
                          style: Theme.of(context).textTheme.bodyText1!),
                    ],
                  ),
                  SizedBox(
                    height: kDefaultPadding / 6,
                  ),
                  Text('Sign in to continue',
                      style: Theme.of(context).textTheme.subtitle2)
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(kDefaultPadding * 3),
                  topRight: Radius.circular(kDefaultPadding * 3),
                ),
                color: boxColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  children: [
                    Form(
                      child: Column(
                        children: [
                          SizedBox(
                            height: kDefaultPadding,
                          ),
                          TextFormField(
                            textAlign: TextAlign.start,
                            keyboardType: TextInputType.visiblePassword,
                            style: TextStyle(
                              color: kTextWhiteColor,
                              fontSize: 17.0,
                              fontWeight: FontWeight.w300,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Username',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              isDense: true,
                            ),
                            validator: (value) {
                              RegExp regExp = new RegExp(emailPattern);
                              if (value == null || value.isEmpty) {
                                return 'Please enter a valid username';
                              } else if (!regExp.hasMatch(value)) {
                                return 'Please enter a valid username';
                              }
                            },
                          ),
                          SizedBox(
                            height: kDefaultPadding,
                          ),
                          TextFormField(
                            obscureText: _passwordVisible,
                            textAlign: TextAlign.start,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: kTextWhiteColor,
                              fontSize: 17.0,
                              fontWeight: FontWeight.w300,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              isDense: true,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                iconSize: kDefaultPadding,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: kDefaultPadding * 2,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Handle simple sign in
                                },
                                child: Text('Sign in',
                                        style :TextStyle(color: kSecondaryColor
                                        ),

                                ),
                              ),
                              SizedBox(height: kDefaultPadding),
                              Text(
                                'or',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: kSecondaryColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: kDefaultPadding),
                              IconButton(
                                onPressed: _authenticateWithFingerprint,
                                icon: Icon(Icons.fingerprint, color: kSecondaryColor, size: 52
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
