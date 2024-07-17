import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/mediaController.dart';
import 'package:magic_sign_mobile/screens/media_screen/DeleteDialog.dart';
import 'package:magic_sign_mobile/model/Media.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:video_player/video_player.dart';

class MediaDialog extends StatefulWidget {
  final Media media;
  final Function(Media) onAddToTimeline;

  MediaDialog({required this.media, required this.onAddToTimeline});

  @override
  State<MediaDialog> createState() => _MediaDialogState();
}

class _MediaDialogState extends State<MediaDialog> {
  VideoPlayerController? _videoPlayerController;
  bool _isControllerInitialized = false;
  IconButton? _playButton;
  IconButton? _pauseButton;
  late MediaController mediaController;

  String formatDuration(String durationString) {
    int duration = int.tryParse(durationString) ?? 0;
    int hours = duration ~/ 3600;
    int minutes = (duration % 3600) ~/ 60;
    int seconds = duration % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<String> _getImageUrl() async {
    await Future.delayed(Duration(seconds: 2));
    return "https://magic-sign.cloud/v_ar/web/MSlibrary/${widget.media.storedAs}";
  }

  @override
  void initState() {
    super.initState();
    mediaController = Get.put(MediaController());
    if (widget.media.mediaType.toLowerCase() == 'video') {
      _videoPlayerController = VideoPlayerController.network(
          'https://magic-sign.cloud/v_ar/web/MSlibrary/${widget.media.storedAs}');
      _videoPlayerController!.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isControllerInitialized = true;
            _playButton = IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () {
                _videoPlayerController!.play();
              },
            );
            _pauseButton = IconButton(
              icon: Icon(Icons.pause),
              onPressed: () {
                _videoPlayerController!.pause();
              },
            );
          });
        }
      }).catchError((error) {
        print('Error initializing video player: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.media.name,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 2),
            if (widget.media.mediaType.toLowerCase() == 'image')
              CachedNetworkImage(
                imageUrl:
                    "https://magic-sign.cloud/v_ar/web/MSlibrary/${widget.media.storedAs}",
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            if (widget.media.mediaType.toLowerCase() == 'video')
              SizedBox(
                height: 200,
                width: 200,
                child: _videoPlayerController?.value.isInitialized ?? false
                    ? AspectRatio(
                        aspectRatio: _videoPlayerController!.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController!),
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            if (_isControllerInitialized && widget.media.mediaType == "video")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [_playButton!, _pauseButton!],
              ),
            if (widget.media.mediaType.toLowerCase() == 'pdf')
              Container(
                width: 300,
                height: 250,
                child: SfPdfViewer.network(
                  "https://magic-sign.cloud/v_ar/web/MSlibrary/${widget.media.storedAs}",
                ),
              ),
            SizedBox(height: 10),
            ElevatedButton(
             onPressed: () {
                widget.onAddToTimeline(widget.media); 
              },

              child: Text("Ajouter à la timeline"),
            ),
          ],
        ),
      ),
      actions: [],
    );
  }
}
