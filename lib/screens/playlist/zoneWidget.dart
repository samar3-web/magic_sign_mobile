import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/controller/mediaController.dart';
import 'package:magic_sign_mobile/controller/playerController.dart';
import 'package:magic_sign_mobile/controller/playlistController.dart';
import 'package:magic_sign_mobile/controller/previewController.dart';
import 'package:magic_sign_mobile/model/Media.dart';
import 'package:magic_sign_mobile/screens/playlist/previewScreen.dart';

class ZoneWidget extends StatefulWidget {
  int zoneId;
  double top;
  double left;
  double width;
  ZoneWidget(
      {super.key,
      required this.zoneId,
      required this.top,
      required this.left,
      required this.width});

  @override
  State<ZoneWidget> createState() => _ZoneWidgetState();
}

class _ZoneWidgetState extends State<ZoneWidget> {
  final PlaylistController playlistController = Get.put(PlaylistController());
  final Previewcontroller previewcontroller = Get.put(Previewcontroller());

  List<Timeline> medias = [];
  @override
  void initState() {
    super.initState();
    print('sss ${Get.width}');
    print(calculLeft(widget.left));
    print(calculWidth(widget.width));
    previewcontroller.getAssignedMedia(widget.zoneId);
  }

  double calculLeft(double left) {
    switch (left) {
      case > 1440:
        return Get.width * 0.75;
      case > 960:
        return Get.width * 0.5;
      case > 480:
        return Get.width * 0.25;
      default:
        return 0;
    }
  }

  double calculWidth(double width) {
    switch (width) {
      case > 1440:
        return Get.width;
      case > 960:
        return Get.width * 0.75;
      case > 480:
        return Get.width * 0.5;
      default:
        return Get.width * 0.25;
    }
  }

  String getFileType(Media media) {
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

  Future<String> getThumbnailUrl(Media media) async {
    String fileType = getFileType(media);
    print('File type: $fileType');
    try {
      if (fileType == 'image') {
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
    return Positioned(
        left: calculLeft(widget.left),
        top: widget.top,
        child: Container(
          height: Get.height * 0.5,
          width: calculWidth(widget.width),
          child: Center(child: Image.asset('assets/images/default.png')),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
        ));
  }
}
