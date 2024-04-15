import 'package:flutter/material.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/widgets/navbar.dart';
import 'package:magic_sign_mobile/screens/my_profile/my_profile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static String routeName = 'HomeScreen';

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldkey,
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
              onPressed: () => scaffoldkey.currentState?.openDrawer(),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 4.5,
            padding: EdgeInsets.all(kDefaultPadding),
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
                        kHalfSizedBox,
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
                SizedBox(
                  height: kDefaultPadding,
                ),
               /* Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2.5,
                        height: MediaQuery.of(context).size.height / 9,
                        decoration: BoxDecoration(
                          color: kOtherColor,
                          borderRadius: BorderRadius.circular(kDefaultPadding),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2.5,
                        height: MediaQuery.of(context).size.height / 9,
                        decoration: BoxDecoration(
                          color: kOtherColor,
                          borderRadius: BorderRadius.circular(kDefaultPadding),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                              '3',
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
                    ),
                  ],
                ),*/
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: kOtherColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(kDefaultPadding * 3),
                  topRight: Radius.circular(kDefaultPadding * 3),
                ),
              ),
              // Add your remaining content here
            ),
          ),
        ],
      ),
    );
  }
}
