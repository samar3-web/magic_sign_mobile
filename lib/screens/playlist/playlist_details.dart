import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/mediaController.dart';
import 'package:magic_sign_mobile/model/Playlist.dart';
import 'package:magic_sign_mobile/model/PlaylistRessource.dart';
import 'package:magic_sign_mobile/model/Playlists.dart';
import 'package:magic_sign_mobile/model/Timeline.dart';
import 'package:magic_sign_mobile/model/Widget.dart';
import 'package:magic_sign_mobile/controller/playlistController.dart';
import 'package:magic_sign_mobile/screens/playlist/previewScreen.dart';
import 'package:magic_sign_mobile/screens/playlist/updateWidget.dart';

import '../../model/Media.dart';

class PlaylistDetail extends StatefulWidget {
  const PlaylistDetail({Key? key, required this.playlist}) : super(key: key);
  static const String routeName = 'PlaylistDetail';
  final Playlist playlist;
  @override
  State<PlaylistDetail> createState() => _PlaylistDetail();
}

class _PlaylistDetail extends State<PlaylistDetail> {
  final MediaController mediaController = Get.put(MediaController());
  final PlaylistController playlistController = Get.put(PlaylistController());
  bool _showScrollIndicator = false;
  Timeline? timeline;
  @override
  void initState() {
    super.initState();
    // Fetch media data for the playlist
    mediaController.getMedia();
    playlistController.getWidget();

    _fetchPlaylist();
  }

  Future<void> _fetchPlaylist() async {
    try {
      print('Fetching assigned media...');
      await playlistController.getAssignedMedia(widget.playlist.layoutId);
      print('Fetching widgets...');
      await playlistController.getWidget();
      print('Data fetched successfully.');

      // Refresh UI
      setState(() {});
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _updatePlaylistDuration() async {
    try {
      int totalDuration = 0;
      for (var timeline in playlistController.timelines!) {
        for (var playlist in timeline.playlists!) {
          for (var widgetData in playlist.widgets!) {
            totalDuration += widgetData.duration ?? 0;
          }
        }
      }
      playlistController.playlistDuration.value = totalDuration;
      print('Playlist duration updated: $totalDuration');

      setState(() {});
    } catch (e) {
      print('Error updating playlist duration: $e');
    }
  }

  String formatDuration(String durationString) {
    int duration = int.tryParse(durationString) ?? 0;
    int hours = duration ~/ 3600;
    int minutes = (duration % 3600) ~/ 60;
    int seconds = duration % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _showConfirmDeleteWidgetDialog(int widgetId) async {
    bool deleteConfirmed = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Widget'),
          content: Text('Are you sure you want to delete this widget?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                deleteConfirmed = true;
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );

    if (deleteConfirmed) {
      playlistController.deleteWidget(widgetId).then((_) {
        setState(() {
          playlistController.getAssignedMedia(widget.playlist.layoutId);
        });
      });
    }
  }

  void _navigateToDetailScreen(Timeline timeline) {
    Get.to(() => PreviewScreen(timeline: timeline), arguments: timeline);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playlist Detail'),
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
                                //_navigateToDetailScreen(timeline!);
                              },
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Duration :  ${formatDuration(widget.playlist.duration)}',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 2.5,
                          child: GridView.builder(
                            padding: EdgeInsets.all(16.0),
                            scrollDirection: Axis.horizontal,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 6.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: mediaController.mediaList.length,
                            itemBuilder: (context, index) {
                              Media media = mediaController.mediaList[index];
                              return InkWell(
                                onTap: () {
                                  //handle Media Pressed
                                  print("media pressed");
                                  print("playlistId: ");
                                  print(widget.playlist.regions[0].playlists[0]
                                      .playlistId);
                                  print("media: ");
                                  print(media.mediaId);
                                  print(media.name);
                                  playlistController.assignPlaylist(
                                      [media.mediaId],
                                      widget.playlist.regions[0].playlists[0]
                                          .playlistId);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 3 -
                                      16,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      media.name,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              );
                            },
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
                                children: [
                                  for (int i = 0;
                                      i < playlistController.timelines!.length;
                                      i++)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text('Timeline ${i + 1}',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            alignment: Alignment.center,
                                            width: 120,
                                            height: 40,
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
                                              children: [
                                                for (Playlists playlist
                                                    in playlistController
                                                        .timelines![i]
                                                        .playlists!)
                                                  for (WidgetData widget
                                                      in playlist.widgets!)
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 1.0),
                                                      child: Container(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            // Condition pour afficher le contenu en fonction du type
                                                            if (widget.mediaIds!
                                                                .isNotEmpty)
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1.0),
                                                                child: Text(
                                                                  '${mediaController.getMediaById(int.parse(widget.mediaIds![0]))?.name}',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              )
                                                            else
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1.0),
                                                                child: Text(
                                                                  widget.type!,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          1.0),
                                                              child: Text(
                                                                '${formatDuration(widget.duration.toString())}',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                IconButton(
                                                                  icon: Icon(
                                                                      Icons
                                                                          .edit),
                                                                  onPressed:
                                                                      () async {
                                                                    String?
                                                                        updatedDuration =
                                                                        await showDialog<
                                                                            String>(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return ModifyDialog(
                                                                          widgetData:
                                                                              widget,
                                                                        );
                                                                      },
                                                                    );
                                                                    if (updatedDuration !=
                                                                        null) {
                                                                      setState(
                                                                          () {
                                                                        widget.duration =
                                                                            int.parse(updatedDuration!);
                                                                      });
                                                                    }
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                    width: 5),
                                                                IconButton(
                                                                  icon: Icon(Icons
                                                                      .delete),
                                                                  onPressed:
                                                                      () {
                                                                    _showConfirmDeleteWidgetDialog(
                                                                        widget
                                                                            .widgetId!);
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        width: 120,
                                                        height: 96,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: boxColor,
                                                          border: Border.all(
                                                            color: boxColor,
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                    ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: IntrinsicWidth(
                child: ElevatedButton(
                  onPressed: () async {
                    await _updatePlaylistDuration();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.save,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Enregistrer',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
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
