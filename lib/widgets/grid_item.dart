import 'dart:io';

import 'package:cached_network_image_builder/cached_network_image_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/controller/connectionController.dart';
import 'package:magic_sign_mobile/model/Media.dart';
import 'package:magic_sign_mobile/screens/media_screen/MediaDialog.dart';
import 'package:magic_sign_mobile/screens/media_screen/media_details_dialog.dart';
import 'package:magic_sign_mobile/controller/mediaController.dart';

class GridItem extends StatelessWidget {
  final Media media;
  final Function(Media) onDoubleTap;

  GridItem({required this.media, required this.onDoubleTap});

  String getFileType() {
    String mediaType = media.mediaType.toLowerCase();

    Map<String, String> fileTypes = {
      'jpg': 'image',
      'image': 'image',
      'pdf': 'pdf',
      'doc': 'word',
      'docx': 'word',
      'xlsx': 'excel',
      'ppt': 'powerpoint',
      'pptx': 'powerpoint',
      'video': 'video',
    };

    return fileTypes.containsKey(mediaType) ? fileTypes[mediaType]! : 'other';
  }

  Future<String> getThumbnailUrl() async {
    var isConnected = await Connectioncontroller.isConnected();
    String fileType = getFileType();
    print('File type: $fileType');
    try {
      if (fileType == 'image') {
        if (isConnected) {
          print('Media ID: ${media.mediaId}');
          return await MediaController().getImageUrl(media.storedAs);
        } else {
          return 'assets/images/logo.jpg';
        }
      } else {
        switch (fileType) {
          case 'word':
            return 'assets/images/word-logo.png';
          case 'pdf':
            return 'assets/images/pdf-logo.png';
          case 'excel':
            return 'assets/images/excel-logo.png';
          case 'powerpoint':
            return 'assets/images/pp-logo.png';
          case 'video':
            return 'assets/images/video-logo.png';
          default:
            return 'assets/images/default.png';
        }
      }
    } catch (e) {
      print('Error loading image: $e');
      return 'assets/images/default.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return MediaDialog(media: media);
          },
        );
      },
      onDoubleTap: () {
        onDoubleTap(media);
      },
      child: FutureBuilder<String>(
        future: getThumbnailUrl(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            String thumbnailUrl = snapshot.data!;
            return Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      child: getFileType() == 'image'
                          ? CachedNetworkImageBuilder(
                              url:
                                  "https://magic-sign.cloud/v_ar/web/MSlibrary/${media.storedAs}",
                              builder: (image) {
                                return Center(child: Image.file(image));
                              },
                            )
                          : Image.asset(
                              thumbnailUrl,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      media.name,
                      style: TextStyle(fontSize: 16.0),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
