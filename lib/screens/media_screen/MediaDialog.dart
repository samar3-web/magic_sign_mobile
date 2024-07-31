import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/controller/loginController.dart';
import 'package:magic_sign_mobile/controller/mediaController.dart';
import 'package:magic_sign_mobile/model/Media.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:video_player/video_player.dart';

class MediaDialog extends StatefulWidget {
  final List<Media> mediaList;
  final int initialIndex;
  final Function(Media) onAddToTimeline;

  MediaDialog({
    required this.mediaList,
    required this.initialIndex,
    required this.onAddToTimeline,
  });

  @override
  State<MediaDialog> createState() => _MediaDialogState();
}

class _MediaDialogState extends State<MediaDialog> {
  PageController? _pageController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoPlayerInitialized = false;
  late MediaController mediaController;
  late String _currentMediaName;

  final LoginController loginController = Get.find();
  String get apiUrl => loginController.baseUrl;

  @override
  void initState() {
    super.initState();
    mediaController = Get.put(MediaController());
    _currentMediaName = widget.mediaList[widget.initialIndex].name;
    _pageController = PageController(initialPage: widget.initialIndex);
    if (widget.mediaList[widget.initialIndex].mediaType.toLowerCase() ==
        'video') {
      _initializeVideoPlayer(widget.mediaList[widget.initialIndex]);
    }
  }

  void _initializeVideoPlayer(Media media) {
    _videoPlayerController = VideoPlayerController.network(
      '${loginController.baseUrl}/web/MSlibrary/${media.storedAs}',
    )..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: true,
            looping: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: Colors.red,
              handleColor: Colors.red,
              backgroundColor: Colors.black,
              bufferedColor: Colors.grey,
            ),
            placeholder: Center(child: CircularProgressIndicator()),
          );
          _isVideoPlayerInitialized = true;
        });
      }).catchError((error) {
        print('Error initializing video player: $error');
        setState(() {
          _isVideoPlayerInitialized = false;
        });
      });
  }

  void _disposeVideoPlayer() {
    _videoPlayerController?.dispose();
    _isVideoPlayerInitialized = false;
  }

  @override
  void dispose() {
    _disposeVideoPlayer();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.mediaList.length,
          onPageChanged: (index) {
            setState(() {
              _currentMediaName = widget.mediaList[index].name;
              if (widget.mediaList[index].mediaType.toLowerCase() == 'video') {
                _disposeVideoPlayer();
                _initializeVideoPlayer(widget.mediaList[index]);
              } else {
                _disposeVideoPlayer();
              }
            });
          },
          itemBuilder: (context, index) {
            final media = widget.mediaList[index];
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (media.mediaType.toLowerCase() == 'image')
                    CachedNetworkImage(
                      imageUrl:
                          "${loginController.baseUrl}/web/MSlibrary/${media.storedAs}",
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  if (media.mediaType.toLowerCase() == 'video')
                    _isVideoPlayerInitialized
                        ? Column(
                            children: [
                              AspectRatio(
                                aspectRatio:
                                    _videoPlayerController!.value.aspectRatio,
                                child: VideoPlayer(_videoPlayerController!),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      _videoPlayerController!.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _videoPlayerController!.value.isPlaying
                                            ? _videoPlayerController!.pause()
                                            : _videoPlayerController!.play();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Center(child: CircularProgressIndicator()),
                  if (media.mediaType.toLowerCase() == 'pdf')
                    Container(
                      width: 300,
                      height: 250,
                      child: SfPdfViewer.network(
                        "${loginController.baseUrl}/web/MSlibrary/${media.storedAs}",
                      ),
                    ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      widget.onAddToTimeline(media);
                    },
                    child: Text("Ajouter à la timeline"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
