import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/screens/media_screen/mediaController.dart';

import '../model/Media.dart';

class PlaylistDetail extends StatefulWidget {
  const PlaylistDetail({super.key});
    static const String routeName = 'PlaylistDetail';


  @override
  State<PlaylistDetail> createState() => _PlaylistDetail();
}

class _PlaylistDetail extends State<PlaylistDetail> {
  final MediaController mediaController = Get.put(MediaController());
  bool _showScrollIndicator = false;

  @override
  void initState() {
    super.initState();
    // Fetch media data for the playlist
    mediaController.getMedia();
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
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 2, 
                        child: GridView.builder(
                          padding: EdgeInsets.all(16.0),

                          scrollDirection: Axis.horizontal,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, 
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: mediaController.mediaList.length,
                          itemBuilder: (context, index) {
                            Media media = mediaController.mediaList[index];
                            return Container(
                              width: MediaQuery.of(context).size.width / 3 - 16, 
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