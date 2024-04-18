import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/playerController.dart';
import 'package:magic_sign_mobile/model/Player.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  static const String routeName = 'PlayerScreen';

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final PlayerController playerController = Get.put(PlayerController());
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    playerController.fetchData();
    print('Player List Length: ${playerController.playerList.length}');

  }

  Future<void> _refreshList() async {
    setState(() {
      _isRefreshing = true;
    });
    await playerController.fetchData();
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Afficheurs'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshList,
        child: Obx(
          () => ListView.builder(
            itemCount: playerController.playerList.length,
            itemBuilder: (context, index) {
              Player player = playerController.playerList[index];
              bool isLoggedIn = player.loggedIn == 1;
              String formattedLastAccessed = player.lastAccessed != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(
                      DateTime.fromMillisecondsSinceEpoch(player.lastAccessed! * 1000))
                  : 'Never accessed';
              if (player.licensed == 0) {
                // If not licensed, return an empty container to remove it from the list
                return Container();
              }

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  title: Row(
                    children: [
                      Text(
                        player.display ?? 'No display',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(width: 10,),
                      CircleAvatar(
                        radius: 6.0,
                        backgroundColor: isLoggedIn ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.0),
                      Text(
                        player.clientAddress?.toString() ?? 'No address',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Text(
                            formattedLastAccessed,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          
                         SizedBox(width: 8.0),
                          Icon(
                            player.licensed == 1 ? Icons.check_circle : Icons.cancel,
                            color: player.licensed == 1 ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: _isRefreshing
          ? null
          : FloatingActionButton(
              onPressed: _refreshList,
              child: Icon(Icons.refresh),
              backgroundColor: kSecondaryColor,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
