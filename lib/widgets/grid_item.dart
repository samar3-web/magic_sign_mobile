import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:magic_sign_mobile/controller/connectionController.dart';
import 'package:magic_sign_mobile/controller/mediaController.dart';
import 'package:magic_sign_mobile/model/Media.dart';
import 'package:magic_sign_mobile/screens/media_screen/MediaDialog.dart';

class GridItem extends StatelessWidget {
  final List<Media> mediaList;
  final int index;
  final Function(Media) onLongPress;
  final Function(Media) onAddToTimeline;

  GridItem({
    required this.mediaList,
    required this.index,
    required this.onLongPress,
    required this.onAddToTimeline,
  });

  Media get media => mediaList[index];

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
    try {
      
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
            return MediaDialog(
              mediaList: mediaList,
              initialIndex: index,
              onAddToTimeline: onAddToTimeline,
            );
          },
        );
      },
      onLongPress: () {
        onLongPress(media);
      },
      child: FutureBuilder<String>(
        future: getThumbnailUrl(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            );
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
                          ? CachedNetworkImage(
                              imageUrl:
                                  "https://magic-sign.cloud/v_ar/web/MSlibrary/${media.storedAs}",
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              fit: BoxFit.cover,
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
