import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/controller/mediaController.dart';
import 'package:magic_sign_mobile/controller/playlistController.dart';
import 'package:magic_sign_mobile/controller/previewController.dart';
import 'package:magic_sign_mobile/model/AssignedMedia.dart';
import 'package:magic_sign_mobile/model/Timeline.dart';
import 'package:magic_sign_mobile/widgets/VideoPlayerWidget.dart';
import 'package:video_player/video_player.dart';

class ZoneWidget extends StatefulWidget {
  int zoneId;
  double top;
  double left;
  double width;
  int layoutId;

  ZoneWidget({
    super.key,
    required this.zoneId,
    required this.top,
    required this.left,
    required this.width,
    required this.layoutId,
  });

  @override
  State<ZoneWidget> createState() => _ZoneWidgetState();
}

class _ZoneWidgetState extends State<ZoneWidget> {
  final PlaylistController playlistController = Get.put(PlaylistController());
  final Previewcontroller previewcontroller = Get.put(Previewcontroller());
  late Duration duration;
  late Timer timer;
  var currentIndex = 0;
  late AssignedMedia media;
  late String fileType;
  late List<AssignedMedia> medias;
  timerCallback() {
    if (currentIndex < medias.length) {
      setState(() {
        currentIndex++;
      });
    } else {
      setState(() {
        currentIndex = 0;
      });
    }
  }

  getAssignedMedia() {}

  @override
  void initState() {
    super.initState();
    previewcontroller.fetchAssignedMedia(widget.layoutId);
    medias = [];

    duration = new Duration(
        seconds: medias.isEmpty ? 0 : int.parse(medias.first.duration));
    timer = new Timer(duration, timerCallback);
  }

  double calculLeft(double left) {
    if (left > 1440) {
      return Get.width * 0.75;
    } else if (left > 960) {
      return Get.width * 0.5;
    } else if (left > 480) {
      return Get.width * 0.25;
    } else {
      return 0;
    }
  }

  double calculWidth(double width) {
    if (width > 1440) {
      return Get.width;
    } else if (width > 960) {
      return Get.width * 0.75;
    } else if (width > 480) {
      return Get.width * 0.5;
    } else {
      return Get.width * 0.25;
    }
  }

  String getFileType(AssignedMedia media) {
    String mediaType = media.type.toLowerCase();

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

  Future<String> getThumbnailUrl(AssignedMedia media) async {
    String fileType = getFileType(media);
    print('File type: $fileType');
    try {
      if (fileType == 'image') {
        print('Media ID: ${media.mediaID}');
        return await MediaController().getImageUrl(media.storedAs);
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
    medias = previewcontroller.mediasList.value
        .firstWhere((t) => t.timelineId == widget.zoneId)
        .mediaList;
    media = medias[currentIndex];

    return Positioned(
      left: calculLeft(widget.left),
      top: widget.top,
      child: Container(
        height: Get.height * 0.5,
        width: calculWidth(widget.width),
        child: Obx(() {
          if (previewcontroller.mediasList.isEmpty) {
            return Center(child: CircularProgressIndicator());
          } else {
            /*return ListView.builder(
              itemCount: previewcontroller.mediasList.firstWhere((t) => t.timelineId == widget.zoneId).mediaList.length,
              itemBuilder: (context, index) {
                AssignedMedia media = previewcontroller.mediasList.firstWhere((t) => t.timelineId == widget.zoneId).mediaList[index];
               
                String fileType = getFileType(media);
*/
            return FutureBuilder<String>(
              future: getThumbnailUrl(medias[currentIndex]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Icon(Icons.error);
                } else {
                  String url = snapshot.data!;
                  return fileType == 'image'
                      ? Center(
                          child: Image.network(
                            "https://magic-sign.cloud/v_ar/web/MSlibrary/${medias[currentIndex].mediaID}",
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.error);
                            },
                          ),
                        )
                      : fileType == 'video'
                          ? VideoPlayerWidget(media: medias[currentIndex])
                          : Image.asset(url);
                }
              },
            );
            //},
            //);
          }
        }),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),
      ),
    );
  }
}
