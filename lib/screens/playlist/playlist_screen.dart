import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/playerController.dart';
import 'package:magic_sign_mobile/model/Playlist.dart';
import 'package:magic_sign_mobile/screens/planification/ScheduleEventScreen.dart';
import 'package:magic_sign_mobile/screens/playlist/addPlaylist.dart';
import 'package:magic_sign_mobile/controller/playlistController.dart';
import 'package:magic_sign_mobile/screens/playlist/playlist_details.dart';
import 'package:magic_sign_mobile/widgets/BaseScreen.dart';

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
  bool _isFabVisible = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    playlistController.getPlaylist();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        setState(() {
          _isFabVisible = false;
        });
      }
      
    });
  }

  /* void _scrollListener() {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels == 0) {
        setState(() {
          _isFabVisible = true;
        });
      } else {
        setState(() {
          _isFabVisible = false;
        });
      }
    } else {
      setState(() {
        _isFabVisible = true;
      });
    }
  }*/

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Playlist',
      body: Scaffold(
        floatingActionButton: _isFabVisible
            ? FloatingActionButton(
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
              )
            : null,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            Colors.white, // Background color of the TextField
                        borderRadius:
                            BorderRadius.circular(12.0), // Radius of the border
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: TextField(
                        style: TextStyle(fontSize: 16.0),
                        decoration: InputDecoration(
                          hintText: 'Rechercher',
                          hintStyle: TextStyle(color: boxColor),
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: kSecondaryColor,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                        onChanged: (value) {
                          playlistController.searchPlaylist(value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
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
                              controller: _scrollController,
                              itemCount: playlistController.playlistList.length,
                              itemBuilder: (context, index) {
                                Playlist playlist =
                                    playlistController.playlistList[index];
                                Color statusColor = playlist.status == '3'
                                    ? Colors.green
                                    : playlist.status == '2'
                                        ? Colors.orange
                                        : Colors.orange;

                                return GestureDetector(
                                  onTap: () =>
                                      _navigateToDetailScreen(playlist),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
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
                                                  .bodyMedium,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Duration: ${formatDuration(playlist.duration)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Owner: ${playlist.owner}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  'Status : ',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
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
                                              child:
                                                  Text('Planifier maintenant'),
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
                                              selectedLayoutId =
                                                  playlist.campaignId;
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return ScheduleEventScreen(
                                                      campaignId:
                                                          selectedLayoutId!);
                                                },
                                              );
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
            ),
          ],
        ),
      ),
    );
  }
}
