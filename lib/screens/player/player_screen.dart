import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/playerController.dart';
import 'package:magic_sign_mobile/controller/playlistController.dart';
import 'package:magic_sign_mobile/model/Player.dart';
import 'package:magic_sign_mobile/model/Playlist.dart';
import 'package:magic_sign_mobile/widgets/BaseScreen.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  static const String routeName = 'PlayerScreen';

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final PlayerController playerController = Get.put(PlayerController());
  final PlaylistController playlistController = Get.put(PlaylistController());
  bool _showOnlyLicensed = false;
  bool _isRefreshing = false;

  final ScrollController _scrollController = ScrollController();
  List<Playlist> playlists = [];

  @override
  void initState() {
    super.initState();
    playerController.fetchData();
    playerController.fetchDisplayGroup();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {}
    });

    print('Player List Length: ${playerController.playerList.length}');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                onPressed: () async {
                  await playerController.authorizePlayer(player.displayId!);
                  setState(() {
                    player.licensed = 1;
                  });
                  Navigator.of(context).pop();
                  Get.snackbar('Succès', 'Afficheur autorisé avec succès');
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

  void _showNonAuthorizeDialog(Player player) {
    if (player.displayId != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text(
                "Voulez-vous vraiment annuler l'autorisation de l'afficheur?"),
            actions: [
              TextButton(
                child: Text('Annuler'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Oui'),
                onPressed: () async {
                  await playerController.authorizePlayer(player.displayId!);
                  setState(() {
                    player.licensed = 0;
                  });
                  Navigator.of(context).pop();
                  Get.snackbar('Succès', 'Afficheur non autorisé avec succès');
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
            title: Text('Sélectionner Playlist'),
            content: DropdownButtonFormField<String>(
              isExpanded: true,
              value: defaultPlaylistName,
              hint: Text('Sélectionner playlist'),
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
                        createdDt: '',
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
                    Get.snackbar("Succès",
                        "Mise en page par défaut attribué avec succès");
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

  void _showDeleteDialog(Player player) {
    if (player.displayId != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation de suppression'),
            content: Text('Voulez-vous vraiment supprimer cet afficheur?'),
            actions: [
              TextButton(
                child: Text('Annuler'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Supprimer'),
                onPressed: () async {
                  await playerController.deletePlayer(player.displayId!);
                  await playerController.fetchData();
                  Navigator.of(context).pop();
                  Get.snackbar('Succès', 'Afficheur supprimé avec succès');
                },
              ),
            ],
          );
        },
      );
    } else {
      Get.snackbar('Error', 'Display ID is null, cannot delete player.');
    }
  }

  void _showEditDialog(Player player) {
    final TextEditingController displayController =
        TextEditingController(text: player.display);
    final TextEditingController licenseController =
        TextEditingController(text: player.license);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier Player'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: displayController,
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w300,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Nom du Player',
                    labelStyle:
                        TextStyle(color: kTextBlackColor, fontSize: 17.0),
                  ),
                ),
                TextField(
                  controller: licenseController,
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w300,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Licence',
                    labelStyle:
                        TextStyle(color: kTextBlackColor, fontSize: 17.0),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Modifier'),
              onPressed: () async {
                await playerController.editPlayer(
                  displayId: player.displayId!,
                  display: displayController.text,
                  defaultLayoutId: player.defaultLayoutId!,
                  licensed: player.licensed!,
                  license: licenseController.text,
                  incSchedule: player.incSchedule!,
                  emailAlert: player.emailAlert!,
                  wakeOnLanEnabled: player.wakeOnLanEnabled!,
                );
                Navigator.of(context).pop();
                Get.snackbar('Succès', 'Player modifié avec succès');
                playerController.fetchData();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Afficheurs',
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
                trackColor: MaterialStateProperty.all(Colors.black12),
                activeThumbImage: const AssetImage('assets/images/error.png'),
                inactiveThumbImage:
                    const AssetImage('assets/images/authorized.png'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _showOnlyLicensed ? 'Non Autorisé' : 'Autorisé ',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              child: RefreshIndicator(
                onRefresh: _refreshList,
                child: Obx(
                  () {
                    List<Player> filteredPlayers = _showOnlyLicensed
                        ? playerController.playerList
                            .where((player) =>
                                player.licensed ==
                                0) // Filtrer les joueurs sans licence
                            .toList()
                        : playerController.playerList
                            .where((player) =>
                                player.licensed ==
                                1) // Filtrer les joueurs avec licence
                            .toList();
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: filteredPlayers.length,
                      itemBuilder: (context, index) {
                        Player player = filteredPlayers[index];
                        bool isLoggedIn = player.loggedIn == 1;
                        String formattedLastAccessed =
                            player.lastAccessed != null
                                ? DateFormat('yyyy-MM-dd HH:mm').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        player.lastAccessed! * 1000))
                                : 'Never accessed';

                        return Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
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
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'Option 1',
                                  child: ListTile(
                                    leading: Icon(Icons.done),
                                    title: Text("Autoriser l'afficheur"),
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'Option 2',
                                  child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Modifier'),
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'Option 3',
                                  child: ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Supprimer '),
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'Option 4',
                                  child: ListTile(
                                    leading: Icon(Icons.web),
                                    title: Text('Mise en page par défaut '),
                                  ),
                                ),
                              ],
                              onSelected: (String value) async {
                                if (value == 'Option 1') {
                                  if (player.licensed == 1) {
                                    _showNonAuthorizeDialog(player);
                                  } else {
                                    _showAuthorizationDialog(player);
                                  }
                                } else if (value == 'Option 2') {
                                  _showEditDialog(player);
                                } else if (value == 'Option 3') {
                                  _showDeleteDialog(player);
                                } else if (value == 'Option 4') {
                                  _showPlaylistPopup(player, playlists);
                                }
                              },
                              child: Icon(Icons.arrow_drop_down),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
