import 'package:flutter/material.dart';
import 'package:magic_sign_mobile/screens/media_screen/DeleteDialog.dart';
import 'package:magic_sign_mobile/screens/media_screen/ModifyDialog.dart';
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
  VideoPlayerController _videoPlayerController =
      VideoPlayerController.asset('');
  bool _isControllerInitialized = false;
  IconButton? _playButton;
  IconButton? _pauseButton;

  @override
  void initState() {
    if (widget.media.mediaType.toLowerCase() == 'video') {
      _videoPlayerController = VideoPlayerController.network(
          'https://magic-sign.cloud/v_ar/web/MSlibrary/${widget.media.storedAs}');

      _videoPlayerController.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isControllerInitialized = true;
            _playButton = IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () {
                _videoPlayerController.play();
              },
            );
            _pauseButton = IconButton(
              icon: Icon(Icons.pause),
              onPressed: () {
                _videoPlayerController.pause();
              },
            );
          });
        }
      }).catchError((error) {
        if (error.toString().contains('initialize_error_not_video')) {
          print('Ignoring VideoPlayerException: ${error.toString()}');
        } else {
          print('Error initializing video player: $error');
        }
      });
    } else {
      setState(() {
        _isControllerInitialized = false;
        _playButton = null;
        _pauseButton = null;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Media Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.media.mediaType.toLowerCase() == 'image')
              Image.network(
                "https://magic-sign.cloud/v_ar/web/MSlibrary/${widget.media.storedAs}",
                fit: BoxFit.cover,
              ),
            if (widget.media.mediaType.toLowerCase() == 'video')
              SizedBox(
                height: 200,
                width: 200,
                child: _videoPlayerController.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController),
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            if (_isControllerInitialized == true &&
                widget.media.mediaType == "video")
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
            Text('Name: ${widget.media.name}'),
            Text('Type: ${widget.media.mediaType}'),
            Text('Duration: ${widget.media.duration}'),
            Text('Owner: ${widget.media.owner}'),
          ],
        ),
      ),
      actions: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ModifyDialog(media: widget.media),
                ),
                child: Text('Modifier'),
              ),
              ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => DeleteDialog(media: widget.media),
                ),
                child: Text('Supprimer'),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }
}
