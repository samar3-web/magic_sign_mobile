import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/mediaController.dart';
import 'package:magic_sign_mobile/screens/media_screen/DeleteDialog.dart';
import 'package:magic_sign_mobile/model/Media.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:video_player/video_player.dart';

class MediaDetailsDialog extends StatefulWidget {
  final Media media;

  MediaDetailsDialog({required this.media});

  @override
  State<MediaDetailsDialog> createState() => _MediaDetailsDialogState();
}

class _MediaDetailsDialogState extends State<MediaDetailsDialog> {
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
      title: Text(widget.media.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => Container(
                child: mediaController.isUpdating.value
                    ? TextField(
                        controller: mediaController.name,
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w300,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle:
                              TextStyle(color: kTextBlackColor, fontSize: 17.0),
                        ),
                      )
                    : Text(
                        'Name: ${widget.media.name}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Type: ${widget.media.mediaType}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Obx(
              () => Container(
                child: mediaController.isUpdating.value
                    ? TextField(
                        controller: mediaController.duration,
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w300,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Duration',
                          labelStyle:
                              TextStyle(color: kTextBlackColor, fontSize: 17.0),
                        ),
                      )
                    : Text(
                        'Duration: ${widget.media.duration}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Owner: ${widget.media.owner}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            if (widget.media.mediaType.toLowerCase() == 'image')
              FutureBuilder<String>(
                future: _getImageUrl(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Image.network(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    );
                  }
                },
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
          ],
        ),
      ),
      actions: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  if (mediaController.isUpdating.value) {
                    mediaController.updateMediaData(
                        widget.media.mediaId,
                        mediaController.name.text,
                        mediaController.duration.text,
                        widget.media.retired);

                    mediaController.isUpdating.value =
                        !mediaController.isUpdating.value;
                  } else {
                    mediaController.isUpdating.value =
                        !mediaController.isUpdating.value;
                    mediaController.name.text = widget.media.name;

                    mediaController.duration.text = widget.media.duration;
                  }
                },
                child: Text('Modifier'),
              ),
              ElevatedButton(
                onPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showDialog(
                      context: context,
                      builder: (context) => DeleteDialog(media: widget.media),
                    );
                  });
                },
                child: Text('Supprimer'),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Fermer'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }
}
