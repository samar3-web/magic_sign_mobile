import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/mediaController.dart';
import 'package:magic_sign_mobile/controller/widgetController.dart';
import 'package:magic_sign_mobile/model/Playlist.dart';
import 'package:magic_sign_mobile/model/Timeline.dart';
import 'package:magic_sign_mobile/controller/playlistController.dart';
import 'package:magic_sign_mobile/screens/media_screen/MediaDialog.dart';
import 'package:magic_sign_mobile/screens/media_screen/media_details_dialog.dart';
import 'package:magic_sign_mobile/screens/playlist/PositioningAlertDialog.dart';
import 'package:magic_sign_mobile/screens/playlist/previewScreen.dart';
import 'package:magic_sign_mobile/widgets/grid_item.dart';

import '../../model/Media.dart';

class PlaylistDetail extends StatefulWidget {
  const PlaylistDetail({Key? key, required this.playlist}) : super(key: key);
  static const String routeName = 'PlaylistDetail';
  final Playlist? playlist;
  @override
  State<PlaylistDetail> createState() => _PlaylistDetail();
}

class _PlaylistDetail extends State<PlaylistDetail> {
  final MediaController mediaController = Get.put(MediaController());
  final PlaylistController playlistController = Get.put(PlaylistController());
  final WidgetController widgetController = Get.put(WidgetController());
  Timeline? timeline;
  Media? media;

  @override
  void initState() {
    super.initState();
    _fetchPlaylist();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchPlaylist() async {
    try {
      await playlistController.getAssignedMedia(widget.playlist!.layoutId);
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  String formatDuration(String durationString) {
    int duration = int.tryParse(durationString) ?? 0;
    int hours = duration ~/ 3600;
    int minutes = (duration % 3600) ~/ 60;
    int seconds = duration % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _navigateToDetailScreen(int layoutId) {
    Get.to(() => PreviewScreen(layoutId: layoutId));
  }

  void _assignMediaToPlaylist(Media media, int timelineId) {
    playlistController.assignPlaylist(
      [media.mediaId],
      timelineId,
      onSuccess: () {
        _showSuccessDialog();
        _refreshAssignedMedia();
      },
      onError: () => _showErrorDialog(),
    );
  }

  void _refreshAssignedMedia() {
    playlistController
        .getAssignedMedia(widget.playlist!.layoutId)
        .then((_) {})
        .catchError((error) {
      print('Error refreshing assigned media: $error');
    });
  }

  Future<void> _showPlaylistSelectionDialog(Media media) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a Timeline', style: TextStyle(fontSize: 20)),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: playlistController.timelines.length,
              itemBuilder: (BuildContext context, int index) {
                Timeline timeline = playlistController.timelines[index];
                return Card(
                  color: kSecondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _assignMediaToPlaylist(media, timeline.timelineId);
                      },
                      child: Text('Timeline ${index + 1}',
                          style: TextStyle(color: Colors.white)),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _assignMediaToPlaylist(media, timeline.timelineId);
                    },
                  ),
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                  elevation: 4,
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Succès'),
        content: Text('Le média a été attribué avec succès..'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Failed to assign media to playlist.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showZonesInDialog() async {
    try {
      final futureZones =
          playlistController.fetchZones(widget.playlist!.layoutId);
      final zones = await futureZones;
      PositioningAlertDialog.show(context, zones);
    } catch (e) {
      print("Error fetching zones data: $e");
    }
  }

  void _showMediaGridDialog() {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    pageBuilder: (BuildContext context, Animation animation,
        Animation secondaryAnimation) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Parcourir les médias'),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: GridView.count(
          padding: EdgeInsets.all(12.0),
          scrollDirection: Axis.vertical,
          crossAxisCount: 2,
          crossAxisSpacing: 6.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 1.0,
          children: List.generate(
            mediaController.mediaList.length,
            (index) {
              return GridItem(
                mediaList: mediaController.mediaList,
                index: index,
                onLongPress: _showPlaylistSelectionDialog,
                onAddToTimeline: (Media) {
                  _showPlaylistSelectionDialog(Media);
                },
              );
            },
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: widget,
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist!.layout,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Obx(
            () => mediaController.isLoading.value
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: Icon(Icons.visibility),
                              color: Colors.grey,
                              onPressed: () {
                                _navigateToDetailScreen(
                                    widget.playlist!.layoutId);
                              },
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Duration :  ${formatDuration(widget.playlist!.duration)}',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            _showMediaGridDialog();
                          },
                          child: Column(
                            children: [
                              Text(
                                'Appuyez pour parcourir les médias',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Image.asset(
                                'assets/images/media.png',
                                fit: BoxFit.cover,
                                height: 150,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        Expanded(
                          child: Container(
                            height: 250,
                            width: MediaQuery.of(context).size.width,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: playlistController.timelines
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  Timeline timeline = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Text('Timeline ${index + 1} ',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          alignment: Alignment.center,
                                          width: 150,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: kSecondaryColor,
                                            border: Border.all(
                                              color: kSecondaryColor,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: timeline.mediaList
                                                .map((Media media) {
                                              int index = timeline.mediaList
                                                  .indexOf(media);
                                              int ordre = index + 1;
                                              print('ordre : $ordre');
                                              return GestureDetector(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                                  child: Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          media.name,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          'Duration :  ${formatDuration(timeline.mediaList[0].duration)}',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            IconButton(
                                                              icon: Icon(
                                                                Icons.edit,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              onPressed:
                                                                  () async {},
                                                            ),
                                                            IconButton(
                                                              icon: Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              onPressed: () {
                                                                if (widget.playlist !=
                                                                        null &&
                                                                    widget
                                                                        .playlist!
                                                                        .regions
                                                                        .isNotEmpty) {
                                                                  final regions = widget
                                                                      .playlist!
                                                                      .regions;

                                                                  for (var region
                                                                      in regions) {
                                                                    print(
                                                                        "Region ID: ${region.regionId}, Name: ${region.name}");
                                                                    print(
                                                                        "display order :  $ordre");

                                                                    widgetController.deleteWidget(
                                                                        region
                                                                            .regionId,
                                                                        ordre);
                                                                    _refreshAssignedMedia();
                                                                  }
                                                                } else {
                                                                  print(
                                                                      "Playlist or regions are null or empty.");
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    alignment: Alignment.center,
                                                    width: 200,
                                                    height: 96,
                                                    decoration: BoxDecoration(
                                                      color: boxColor,
                                                      border: Border.all(
                                                        color: boxColor,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
