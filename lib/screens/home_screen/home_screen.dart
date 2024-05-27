import 'package:flutter/material.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/widgets/navbar.dart';
import 'package:magic_sign_mobile/screens/my_profile/my_profile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static String routeName = 'HomeScreen';

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      drawer: NavBar(),
      backgroundColor: boxColor,
      body: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 30,
            leading: IconButton(
              icon: Icon(Icons.menu),
              color: Colors.white,
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Samar',
                          style:
                              Theme.of(context).textTheme.subtitle1?.copyWith(
                                    fontWeight: FontWeight.w200,
                                    color: Colors.white,
                                  ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '2023-2024',
                          style:
                              Theme.of(context).textTheme.subtitle2?.copyWith(
                                    fontWeight: FontWeight.w200,
                                    color: Colors.white,
                                  ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, MyProfile.routeName);
                      },
                      child: CircleAvatar(
                        minRadius: 50.0,
                        maxRadius: 50.0,
                        backgroundColor: kSecondaryColor,
                        backgroundImage:
                            AssetImage('assets/images/admin_profile.png'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: kDefaultPadding),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: kOtherColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(kDefaultPadding * 2.5),
                    topRight: Radius.circular(kDefaultPadding * 2.5),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: kDefaultPadding * 1.5),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 2.5,
                            height: MediaQuery.of(context).size.height / 9,
                            margin: EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              color: kOtherColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(kDefaultPadding * 0.5),
                              ),
                              border: Border.all(
                                  color: kSecondaryColor, width: 2.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Utilisateurs',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w800,
                                        color: kTextBlackColor,
                                      ),
                                ),
                                Text(
                                  '2',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.w300,
                                        color: kTextBlackColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2.5,
                            height: MediaQuery.of(context).size.height / 9,
                            margin: EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              color: kOtherColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(kDefaultPadding * 0.5),
                              ),
                              border: Border.all(
                                  color: kSecondaryColor, width: 2.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Afficheurs',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w800,
                                        color: kTextBlackColor,
                                      ),
                                ),
                                Text(
                                  '2',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.w300,
                                        color: kTextBlackColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2.5,
                            height: MediaQuery.of(context).size.height / 9,
                            margin: EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              color: kOtherColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(kDefaultPadding * 0.5),
                              ),
                              border: Border.all(
                                  color: kSecondaryColor, width: 2.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ' Médiathèque',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w800,
                                        color: kTextBlackColor,
                                      ),
                                ),
                                Text(
                                  '2',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.w300,
                                        color: kTextBlackColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: kDefaultPadding),
                    Text(
                      'Activité des afficheurs',
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 20,
                          ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: kDefaultPadding),
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height / 4,
                      color: Colors.white,
                      child: Center(),
                    ),
                    Text(
                      'Utilisation de la Médiathèque',
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 20,
                          ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: kDefaultPadding),
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height / 4,
                      color: Colors.white,
                      child: Center(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
