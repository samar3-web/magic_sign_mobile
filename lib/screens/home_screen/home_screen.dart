import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/navbar.dart';
import 'package:magic_sign_mobile/screens/my_profile/my_profile.dart';
import 'package:sizer/sizer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static String routeName = 'HomeScreen';

  @override
  Widget build(BuildContext context) {
    double height = 40; // Initialize height with a default value

    double width = 100;
    return Scaffold(

        drawer: NavBar(),
        /*
        appBar: AppBar(
          title: const Text('Dashboard'),
          backgroundColor: boxColor,
          elevation: 0,

        ),
*/
        backgroundColor: boxColor,
        body: Column(
          children: [
            
            //we will divide the screen into two parts
            //fixed height for first half
            Container(
              //width: width,
              //height: height,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.5,
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
                              Positioned(
                          top: 20.0,
                       
                        child: IconButton(
                  icon: Icon(Icons.menu),
                                  color: Colors.white, // Set icon color to white

                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                        ),
                          Text(
                            'Samar',
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                ?.copyWith(
                                    fontWeight: FontWeight.w200,
                                    color: Colors.white),
                          ),
                          kHalfSizedBox,
                          Text(
                            '2023-2024',
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2
                                ?.copyWith(
                                    fontWeight: FontWeight.w200,
                                    color: Colors.white),
                          ),
                        ],
                      ),
                      kHalfSizedBox,
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
                      )
                    ],
                  ),
                  SizedBox(
                    height: kDefaultPadding,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2.5,
                          height: MediaQuery.of(context).size.height / 9,
                          decoration: BoxDecoration(
                            color: kOtherColor,
                            borderRadius:
                                BorderRadius.circular(kDefaultPadding),
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
                                        color: kTextBlackColor),
                              ),
                              Text(
                                '2',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.w300,
                                        color: kTextBlackColor),
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
                            borderRadius:
                                BorderRadius.circular(kDefaultPadding),
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
                                        color: kTextBlackColor),
                              ),
                              Text(
                                '3',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.w300,
                                        color: kTextBlackColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                 
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
              ),
            ),
          ],
        ));
  }
}
