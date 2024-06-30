import 'package:flutter/material.dart';
import 'package:magic_sign_mobile/controller/mediaController.dart';
import 'package:magic_sign_mobile/model/AssignedMedia.dart';
import 'package:magic_sign_mobile/widgets/VideoPlayerWidget.dart';

class Timelinewidget extends StatefulWidget {
  String fileType;
  AssignedMedia media;
   Timelinewidget({required this.fileType,required this.media});

  @override
  State<Timelinewidget> createState() => _TimelinewidgetState();
}

class _TimelinewidgetState extends State<Timelinewidget> {

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
    return FutureBuilder<String>(
      future: getThumbnailUrl(widget.media),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Icon(Icons.error);
        } else {
          String url = snapshot.data!;
          return widget.fileType == 'image'
              ? Center(
                  child: Image.network(
                    "https://magic-sign.cloud/v_ar/web/MSlibrary/${widget.media.mediaID}",
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
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
              : widget.fileType == 'video'
                  ? VideoPlayerWidget(media:widget.media)
                  : Image.asset(url);
        }
      },
    );
  }
}
