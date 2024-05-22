import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/playerController.dart';
import 'package:magic_sign_mobile/controller/playlistController.dart';
import 'package:magic_sign_mobile/model/Player.dart';
import 'package:magic_sign_mobile/model/Playlist.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  static const String routeName = 'PlayerScreen';

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final PlayerController playerController = Get.put(PlayerController());
  final PlaylistController playlistController = Get.put(PlaylistController());
  bool _isRefreshing = false;
  bool _showOnlyLicensed = false;
  bool _isFabVisible = true;
  List<Playlist> playlists = [];

  @override
  void initState() {
    super.initState();
    playerController.fetchData();
    playerController.fetchDisplayGroup();
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

  Future<void> _fetchPlaylists() async {
    await playlistController.getPlaylist();
  }

  void _showAuthorizationDialog(Player player) {
    if (player.displayId != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text('Voulez-vous autoriser cet afficheur?'),
            actions: [
              TextButton(
                child: Text('Annuler'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Autoriser'),
                onPressed: () {
                  playerController.authorizePlayer(player.displayId!);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      Get.snackbar('Error', 'Display ID is null, cannot authorize player.');
    }
  }

  Future<void> _showPlaylistPopup(
      Player player, List<Playlist> playlists) async {
    try {
      if (playlists.isEmpty) {
        print("Fetching playlists as the list is empty...");
        await _fetchPlaylists();
        playlists = playlistController.playlistList;
        print("Playlists fetched: ${playlists.length}");
      }

      List<String> playlistNames =
          playlists.map((playlist) => playlist.layout).toList();
      print("Playlist names extracted: $playlistNames");

      String? selectedPlaylistName = playlistController.selectedPlaylist.value;

      String? defaultPlaylistName = player.defaultLayout;
      print("Default playlist: $defaultPlaylistName");

      if (defaultPlaylistName != null &&
          !playlistNames.contains(defaultPlaylistName)) {
        playlistNames.add(defaultPlaylistName);
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Playlist'),
            content: DropdownButtonFormField<String>(
              isExpanded: true,
              value: defaultPlaylistName,
              hint: Text('Select a playlist'),
              onChanged: (String? newValue) async {
                if (newValue != null) {
                  try {
                    Playlist selectedPlaylist = playlists.firstWhere(
                      (playlist) => playlist.layout == newValue,
                      orElse: () => Playlist(
                        layout: newValue,
                        layoutId: 2,
                        campaignId: 2,
                        status: '',
                        duration: '',
                        owner: '',
                        playlistId: 2,
                        regions: [],
                      ),
                    );
                    await playerController.setDefaultLayout(
                        player.displayId!, selectedPlaylist.layoutId);
                    playlistController.selectedPlaylist.value = newValue;

                    await playerController.fetchData();

                    setState(() {
                      defaultPlaylistName = newValue;
                    });

                    Navigator.of(context).pop();
                  } catch (e) {
                    print("Error setting default layout: $e");
                    Get.snackbar("Erreur",
                        "Une erreur s'est produite lors de la définition de la mise en page par défaut.");
                  }
                }
              },
              items: playlistNames
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      );
    } catch (e) {
      print("Error in _showPlaylistPopup: $e");
      Get.snackbar("Erreur",
          "Une erreur s'est produite lors de l'affichage des playlists.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Afficheurs'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Switch(
                value: _showOnlyLicensed,
                onChanged: (value) {
                  setState(() {
                    _showOnlyLicensed = value;
                  });
                },
                activeColor: const Color.fromARGB(255, 148, 144, 144),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _showOnlyLicensed
                      ? 'Autorisé ? : Non Autorisé'
                      : 'Affiché: Tout',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollStartNotification) {
                  setState(() {
                    _isFabVisible = false;
                  });
                } else if (scrollNotification is ScrollEndNotification ||
                    scrollNotification is ScrollUpdateNotification) {
                  setState(() {
                    _isFabVisible = true;
                  });
                }
                return true;
              },
              child: RefreshIndicator(
                onRefresh: _refreshList,
                child: Obx(
                  () => ListView.builder(
                    itemCount: playerController.playerList.length,
                    itemBuilder: (context, index) {
                      Player player = playerController.playerList[index];
                      bool isLoggedIn = player.loggedIn == 1;
                      String formattedLastAccessed = player.lastAccessed != null
                          ? DateFormat('yyyy-MM-dd HH:mm').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  player.lastAccessed! * 1000))
                          : 'Never accessed';

                      if (_showOnlyLicensed && player.licensed == 1) {
                        return Container();
                      }

                      return Container(
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
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
                              SizedBox(
                                width: 10,
                              ),
                              CircleAvatar(
                                radius: 6.0,
                                backgroundColor:
                                    isLoggedIn ? Colors.green : Colors.red,
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8.0),
                              Text(
                                player.clientAddress?.toString() ??
                                    'No address',
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
                                    player.licensed == 1
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: player.licensed == 1
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'Option 1',
                                child: Text("Autoriser l'afficheur"),
                              ),
                              const PopupMenuItem<String>(
                                value: 'Option 2',
                                child: Text('Modifier'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'Option 3',
                                child: Text('Supprimer '),
                              ),
                              const PopupMenuItem<String>(
                                value: 'Option 4',
                                child: Text('Mise en page par défaut '),
                              ),
                            ],
                            onSelected: (String value) async {
                              if (value == 'Option 1') {
                                _showAuthorizationDialog(player);
                              } else if (value == 'Option 2') {
                                // Handle the modify logic here
                              } else if (value == 'Option 3') {
                                // Handle the delete logic here
                              } else if (value == 'Option 4') {
                                _showPlaylistPopup(player, playlists);
                              }
                            },
                            child: Icon(Icons.arrow_drop_down),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _isRefreshing || !_isFabVisible
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
