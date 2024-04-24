import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/playerController.dart';
import 'package:magic_sign_mobile/model/Playlist.dart';
import 'package:magic_sign_mobile/screens/playlist/addPlaylist.dart';
import 'package:magic_sign_mobile/controller/playlistController.dart';
import 'package:magic_sign_mobile/screens/playlist/playlist_details.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);
  static const String routeName = 'PlaylistScreen';

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final PlaylistController playlistController = Get.put(PlaylistController());
  final PlayerController playerController = Get.put(PlayerController());
  int? selectedLayoutId;
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    playlistController.getPlaylist();
  }

  String formatDuration(String durationString) {
    int duration = int.tryParse(durationString) ?? 0;
    int hours = duration ~/ 3600;
    int minutes = (duration % 3600) ~/ 60;
    int seconds = duration % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _navigateToDetailScreen(Playlist playlist) {
    Get.to(() => PlaylistDetail(playlist: playlist), arguments: playlist);
  }

  Future<void> _showEditLayoutNameDialog(
      int layoutId, String currentName) async {
    String newName = currentName;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Modifier la mise en page',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
                labelText: 'Nom',
                labelStyle: TextStyle(color: kTextBlackColor, fontSize: 17.0)),
            controller: TextEditingController(text: currentName),
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w300,
            ),
            onChanged: (value) {
              newName = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                playlistController.editLayout(layoutId, newName).then((_) {
                  playlistController.getPlaylist();
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmDeleteDialog(int layoutId, String layoutName) async {
    bool deleteConfirmed = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Supprimer "$layoutName"'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Êtes-vous sûr de vouloir supprimer cette mise en page ?'),
              SizedBox(height: 8),
              Text(
                'Tous les médias non attribués à une Mise en page comme les textes et les flux RSS seront perdus. La Mise en page sera également supprimée de toutes les planifications.',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                deleteConfirmed = true;
                Navigator.of(context).pop();
              },
              child: Text('Oui'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Non'),
            ),
          ],
        );
      },
    );

    if (deleteConfirmed) {
      playlistController.deleteLayout(layoutId).then((_) {
        playlistController.getPlaylist();
      });
    }
  }

  Future<void> _showScheduleDialog(int campaignId) async {
    List<dynamic> displayGroupIds = await playerController.fetchData();

    List<int> selectedDisplayGroupIds = [];
    TextEditingController fromDtController = TextEditingController();
    TextEditingController toDtController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Planifier un événement'),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
                color: Color(0xFFFFFFFFF),
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: displayGroupIds.map((groupId) {
                  return CheckboxListTile(
                    title: Text(
                      'Afficheur ${groupId['name']}',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    value: selectedDisplayGroupIds.contains(groupId['id']),
                     autofocus: false,
                        activeColor: Colors.green,
                        checkColor: Colors.white,
                        selected: selectedDisplayGroupIds.contains(groupId['id']),
                      
                    onChanged: (bool? value) {
                      setState(() {
                        
                        if (value!) {
                          selectedDisplayGroupIds.add(groupId['id']);

                        } else {
                          selectedDisplayGroupIds.remove(groupId['id']);
                        }
                                      _isChecked = value;
print('After update: $selectedDisplayGroupIds');

                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }).toList(),
              ),
            ),
          ),
          actions: <Widget>[
            TextField(
              controller: fromDtController,
                       style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w300,
                            ),
              decoration: InputDecoration(
                  labelText: 'Date de début (YYYY-MM-DD HH:MM:SS)',
                  labelStyle:
                      TextStyle(color: kTextBlackColor, fontSize: 12.0)),
            ),
            TextField(
              controller: toDtController,
                       style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w300,
                            ),
              decoration: InputDecoration(
                  labelText: 'Date de fin (YYYY-MM-DD HH:MM:SS)',
                  labelStyle:
                      TextStyle(color: kTextBlackColor, fontSize: 12.0)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                String fromDt = fromDtController.text;
                String toDt = toDtController.text;

                if (selectedDisplayGroupIds.isNotEmpty) {
                  playlistController
                      .scheduleEvent(
                          campaignId, selectedDisplayGroupIds, fromDt, toDt)
                      .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Event scheduled successfully')),
                    );
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    print(
                        'Erreur lors de la planification de l\'événement: $error');
                  });
                } else {
                  print(
                      'Veuillez sélectionner au moins un groupe d\'affichage.');
                }
              },
              child: Text('Planifier'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playlist'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddLayoutPopup();
            },
          );
        },
        backgroundColor: kSecondaryColor,
        child: Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: TextStyle(fontSize: 16.0),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: boxColor),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                playlistController.searchPlaylist(value);
              },
            ),
          ),
          Expanded(
            child: Center(
              child: Obx(
                () => RefreshIndicator(
                  onRefresh: playlistController.getPlaylist,
                  child: playlistController.playlistList.isEmpty
                      ? Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : ListView.builder(
                          itemCount: playlistController.playlistList.length,
                          itemBuilder: (context, index) {
                            Playlist playlist =
                                playlistController.playlistList[index];
                            Color statusColor = playlist.status == '3'
                                ? Colors.green
                                : playlist.status == '2'
                                    ? Colors.orange
                                    : Colors.transparent;

                            return GestureDetector(
                              onTap: () => _navigateToDetailScreen(playlist),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: Container(
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
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Layout: ${playlist.layout}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Duration: ${formatDuration(playlist.duration)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Owner: ${playlist.owner}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              'Status : ',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2,
                                            ),
                                            SizedBox(width: 4),
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: statusColor,
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
                                          child: Text('Editer'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'Option 2',
                                          child: Text('Supprimer'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'Option 3',
                                          child: Text('Planifier maintenant'),
                                        ),
                                      ],
                                      onSelected: (String value) {
                                        if (value == 'Option 1') {
                                          _showEditLayoutNameDialog(
                                              playlist.layoutId,
                                              playlist.layout);
                                        } else if (value == 'Option 2') {
                                          _showConfirmDeleteDialog(
                                              playlist.layoutId,
                                              playlist.layout);
                                        } else if (value == 'Option 3') {
                                          selectedLayoutId = playlist.layoutId;
                                          _showScheduleDialog(
                                              selectedLayoutId!);
                                        }
                                      },
                                      child: Icon(Icons.arrow_drop_down),
                                    ),
                                  ),
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
    );
  }
}
