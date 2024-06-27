import 'package:cached_network_image_builder/cached_network_image_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/controller/mediaController.dart';
import 'package:magic_sign_mobile/controller/playerController.dart';
import 'package:magic_sign_mobile/controller/playlistController.dart';
import 'package:magic_sign_mobile/controller/previewController.dart';
import 'package:magic_sign_mobile/model/AssignedMedia.dart';
import 'package:magic_sign_mobile/model/Media.dart';
import 'package:magic_sign_mobile/model/Timeline.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart'; // Import video player package

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

  List<Timeline> medias = [];
  AssignedMedia? media; // Nullable media object

  @override
  void initState() {
    super.initState();
    VideoPlayerController? _videoPlayerController;

    print('sss ${Get.width}');
    print(calculLeft(widget.left));
    print(calculWidth(widget.width));
    previewcontroller.fetchAssignedMedia(widget.layoutId);
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
            final List<AssignedMedia> allMedia = previewcontroller.mediasList
                .expand((timeline) => timeline.mediaList)
                .toList();

            return ListView.builder(
              itemCount: allMedia.length,
              itemBuilder: (context, index) {
                AssignedMedia media = allMedia[index];
                print('Media ID: ${media.mediaID}');
                print('Name: ${media.name}');
                print('Type: ${media.type}');
                print('Duration: ${media.duration}');
                String fileType = getFileType(media);

                return FutureBuilder<String>(
                  future: getThumbnailUrl(media),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Icon(Icons.error);
                    } else {
                      String url = snapshot.data!;
                      print(url);
                      return fileType == 'image'
                          ? Image.network(
                              "https://magic-sign.cloud/v_ar/web/MSlibrary/${media.mediaID}",
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.error);
                              },
                            )
                          : fileType == 'video'
                              ? VideoPlayerWidget(
                                  media:
                                      media) 
                              : Image.asset(url);
                    }
                  },
                );
              },
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

class VideoPlayerWidget extends StatefulWidget {
  final AssignedMedia media;

  VideoPlayerWidget({required this.media});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        "https://magic-sign.cloud/v_ar/web/MSlibrary/${widget.media.mediaID}")
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Center(child: CircularProgressIndicator());
  }
}
