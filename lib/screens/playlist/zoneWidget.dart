import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/controller/mediaController.dart';
import 'package:magic_sign_mobile/controller/playlistController.dart';
import 'package:magic_sign_mobile/controller/previewController.dart';
import 'package:magic_sign_mobile/model/AssignedMedia.dart';
import 'package:magic_sign_mobile/model/Timeline.dart';
import 'package:magic_sign_mobile/screens/playlist/TimelineWidget.dart';
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
  Duration duration = new Duration(seconds: 0);
  Timer? timer;
  var currentIndex = 0;
  late AssignedMedia media;
  late String fileType;
  late List<AssignedMedia> medias;
  timerCallback() async {
    print('timer callback is called ');
    List<AssignedMedia> media = await getTimeline();
    if (mounted) {
      timer!.cancel();

      if (currentIndex < media.length - 1) {
        setState(() {
          currentIndex++;
        });
      } else {
        setState(() {
          currentIndex = 0;
        });
      }
    }
  }

  getAssignedMedia() {}

  @override
  void initState() {
    super.initState();
    previewcontroller.fetchAssignedMedia(widget.layoutId);
    medias = [];
  }

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
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

  getTimeline() async {
    medias = previewcontroller.mediasList
        .firstWhere((t) => t.timelineId == widget.zoneId)
        .mediaList;
    return medias;
  }

  @override
  Widget build(BuildContext context) {
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
            return Obx(
              () => FutureBuilder(
                future: getTimeline(),
                builder: (context, data) {
                  if (data.hasData) {
                    List<AssignedMedia> AllList =
                        data.data as List<AssignedMedia>;
                    AssignedMedia media = AllList[currentIndex];
                    duration = new Duration(seconds: int.parse(media.duration));
                    timer = new Timer(duration, timerCallback);

                    print(
                        "currentIndex $currentIndex has duration ${media.duration}");
                    String fileType = getFileType(media);

                    return Timelinewidget(
                      fileType: fileType,
                      media: AllList[currentIndex],
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            );
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
