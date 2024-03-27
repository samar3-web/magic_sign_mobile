import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/screens/media_screen/mediaController.dart';
import 'package:magic_sign_mobile/screens/model/Playlist.dart';
import 'package:magic_sign_mobile/screens/playlist/playlistController.dart';

import '../model/Media.dart';

class PlaylistDetail extends StatefulWidget {
  const PlaylistDetail({Key? key}) : super(key: key);
  static const String routeName = 'PlaylistDetail';

  @override
  State<PlaylistDetail> createState() => _PlaylistDetail();
}

class _PlaylistDetail extends State<PlaylistDetail> {
  final MediaController mediaController = Get.put(MediaController());
  final PlaylistController playlistController = Get.put(PlaylistController());
  bool _showScrollIndicator = false;
  //late Playlist? playlist;

  @override
  void initState() {
    super.initState();
    // Fetch media data for the playlist
    mediaController.getMedia();
    _fetchPlaylist();
  }

  // Method to fetch the playlist asynchronously
  Future<void> _fetchPlaylist() async {
    await playlistController.getPlaylist();
    /*setState(() {
      // Assign the playlist when it's fetched
      playlist = playlistController.playlistList.isNotEmpty
          ? playlistController.playlistList.first
          : null;
    });*/
  }

  String formatDuration(String durationString) {
    int duration = int.tryParse(durationString) ?? 0;
    int hours = duration ~/ 3600;
    int minutes = (duration % 3600) ~/ 60;
    int seconds = duration % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playlist Detail'),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            setState(() {
              _showScrollIndicator = true;
            });
          } else if (notification is ScrollEndNotification) {
            setState(() {
              _showScrollIndicator = false;
            });
          }
          return true;
        },
        child: Stack(
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
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(Icons.visibility, color: Colors.grey),
                              SizedBox(width: 5),
                              Text(
                                'Duration : 00:00:10',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  5), 
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
                                return Container(
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
                                );
                              },
                            ),
                          ),
                          // Add the text timeline here
                          SizedBox(height: 5),
                          Text(
                            'Timeline',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kSecondaryColor,
                            ),
                          ),
                          SizedBox(height:5),
                          Row(
                            children: [
                          Container(
                            alignment: Alignment.bottomLeft,
                          width: 150, 
                          height: 70, 
                          decoration: BoxDecoration(
                            color: kSecondaryColor, 
                            border: Border.all(
                              color: kSecondaryColor, 
                              width: 2, 
                            ),
                            borderRadius: BorderRadius.circular(10), 
                          ),
                        ),
                            ],
                          ),

                        ],
                      ),
                    ),
            ),
            if (_showScrollIndicator)
              Positioned(
                bottom: 20.0,
                left: 0,
                right: 0,
                child: Center(
                  child: Icon(Icons.arrow_forward, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}