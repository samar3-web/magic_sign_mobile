import 'package:flutter/material.dart';
import 'package:magic_sign_mobile/constants.dart';

class MyProfile extends StatelessWidget {
    static String routeName = 'MyProfile';

  const MyProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile' ,style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w200,color: Colors.white)),
        actions: [
          Container(
            child: Row(
              children: [
                Icon(Icons.report_gmailerrorred_outlined,color: Colors.white),
                kWidthSizedBox ,
              ]),
          )
        ],
      ),
      body: Container(
        color: kOtherColor,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: boxColor,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(kDefaultPadding * 2),
                  bottomLeft: Radius.circular(kDefaultPadding * 2),
                ) ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     CircleAvatar(
                            minRadius: 50.0,
                            maxRadius: 50.0,
                            backgroundColor: kSecondaryColor,
                            backgroundImage:
                                AssetImage('assets/images/admin_profile.png'),
                          ),
                kWidthSizedBox,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Admin', style: Theme.of(context).textTheme.titleMedium,),
                  ],
                )
        
                ],),
        
        
            )
        
        ],),
      ),
    );
  }
}