import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/loginController.dart';
import 'package:magic_sign_mobile/controller/mediaController.dart';
import 'package:magic_sign_mobile/controller/playerController.dart';
import 'package:magic_sign_mobile/model/Media.dart';
import 'package:magic_sign_mobile/widgets/DonutChart.dart';
import 'package:magic_sign_mobile/widgets/navbar.dart';
import 'package:magic_sign_mobile/screens/my_profile/my_profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static String routeName = 'HomeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlayerController playerController = Get.put(PlayerController());
  final MediaController mediaController = Get.put(MediaController());
  final LoginController loginController = Get.put(LoginController());

  List<dynamic> users = [];
  List<dynamic> player = [];
  double totalFileSizeMB = 0.0;

  @override
  void initState() {
    super.initState();
    loginController.fetchUsers().then((data) {
      setState(() {
        users = data;
      });
    }).catchError((error) {
      print('Failed to fetch users: $error');
    });

    playerController.fetch().then((data) {
      setState(() {
        player = data;
      });
    }).catchError((error) {
      print('Failed to fetch players: $error');
    });

    mediaController.getMedia().then((_) {
      setState(() {
        totalFileSizeMB = calculateTotalFileSizeInMB(mediaController.mediaList);
      });
    });
  }

  double calculateTotalFileSizeInMB(List<Media> mediaItems) {
    int totalFileSizeBytes = mediaItems.fold(
        0, (sum, item) => sum + (int.tryParse(item.fileSize) ?? 0));
    return totalFileSizeBytes / (1024 * 1024);
  }

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
                          'Admin',
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
                          buildInfoCard(
                              context, 'Utilisateurs', users.length.toString()),
                          buildInfoCard(
                              context, 'Afficheurs', player.length.toString()),
                          buildInfoCard(context, 'Médiathèque',
                              totalFileSizeMB.toStringAsFixed(2) + ' MB'),
                        ],
                      ),
                    ),
                    SizedBox(height: kDefaultPadding),
                    Text(
                      'Activité des afficheurs',
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
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
                      child: FutureBuilder<List<dynamic>>(
                        future: playerController.fetch(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(child: Text('No data available'));
                          } else {
                            return buildTable(snapshot.data!);
                          }
                        },
                      ),
                    ),
                    Text(
                      'Utilisation de la Médiathèque',
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 20,
                          ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: kDefaultPadding),
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height / 2,
                      color: Colors.white,
                      child: FutureBuilder<List<Media>>(
                        future: mediaController.fetchMediaData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(child: Text('No data available'));
                          } else {
                            final mediaSizes =
                                calculateMediaSizes(snapshot.data!);
                            return DonutChart(data: mediaSizes);
                          }
                        },
                      ),
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

  Widget buildInfoCard(BuildContext context, String title, String count) {
    return Container(
      width: MediaQuery.of(context).size.width / 2.5,
      height: MediaQuery.of(context).size.height / 9,
      margin: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: kOtherColor,
        borderRadius: BorderRadius.all(
          Radius.circular(kDefaultPadding * 0.5),
        ),
        border: Border.all(color: kSecondaryColor, width: 2.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyText2!.copyWith(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                  color: kTextBlackColor,
                ),
          ),
          Text(
            count,
            style: Theme.of(context).textTheme.bodyText2!.copyWith(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w300,
                  color: kTextBlackColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget buildTable(List<dynamic> data) {
    List<dynamic> authorizedPlayers =
        data.where((item) => item['authorized'] == 1).toList();
    print('Authorized Players: $authorizedPlayers');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith((states) => boxColor),
          columns: [
            DataColumn(
              label: Container(
                child:
                    Text('Afficheur(s)', style: TextStyle(color: Colors.white)),
              ),
            ),
            DataColumn(
              label: Container(
                padding: EdgeInsets.all(8.0),
                child: Text('Connecté', style: TextStyle(color: Colors.white)),
              ),
            ),
            DataColumn(
              label: Container(
                padding: EdgeInsets.all(8.0),
                child: Text('Autorisé', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
          rows: authorizedPlayers.map((item) {
            bool isConnected = item['connected'] == 1;

            return DataRow(
              cells: [
                DataCell(Text(item['name'] ?? 'Unknown')),
                DataCell(
                  Icon(isConnected ? Icons.circle : Icons.circle,
                      color: isConnected ? Colors.blue : Colors.red, size: 15),
                ),
                DataCell(
                  Icon(Icons.circle, color: Colors.blue, size: 15),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
