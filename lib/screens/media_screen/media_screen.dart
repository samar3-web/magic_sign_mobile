import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/screens/media_screen/mediaController.dart';
import 'package:magic_sign_mobile/screens/media_screen/media_details_dialog.dart';
import 'package:magic_sign_mobile/screens/model/Media.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({Key? key}) : super(key: key);
  static const String routeName = 'MediaScreen';

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  final MediaController mediaController = Get.put(MediaController());
    Future<void> _refreshMedia() async {
    await mediaController.getMedia();
  }

  @override
  void initState() {
    super.initState();
    mediaController.getMedia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Media Screen'),
      ),
     floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Call function to select and upload files
          List<File> pickedFiles = await _selectFiles();
          if (pickedFiles.isNotEmpty) {
            mediaController.uploadFiles(pickedFiles);
          }
        },
        backgroundColor: kSecondaryColor,
        child: Icon(Icons.add),
      ),
      body: RefreshIndicator(
      onRefresh: _refreshMedia,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
             child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(fontSize: 16.0),

                    decoration: InputDecoration(
                      
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: boxColor),
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    
                    ),
                    onChanged: (value) {
                      mediaController.searchMedia(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                DropdownButton<String>(
                  onChanged: (String? newValue) {
                    setState(() {
                      mediaController.filterByType(newValue!);
                    });
                  },
                  items: <String>['Image', 'PDF', 'Word', 'Excel', 'PowerPoint', 'Video']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  hint: Text('Filter by type'),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  onChanged: (String? newValue) {
                    setState(() {
                      mediaController.filterByOwner(newValue!);
                    });
                  },
                  items: <String>['ADMIN', 'SUPERADMIN']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  hint: Text('Filter by owner'),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Obx(
              () => mediaController.isLoading.value
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : GridViewUI(mediaList: mediaController.mediaList),
            ),
          ),
        ],
      ),
      ),
    );
  }

}

Future<List<File>> _selectFiles() async {
  FilePickerResult? results = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
  );

  if (results != null) {
    return results.files.map((file) => File(file.path!)).toList();
  } else {
    return [];
  }
}




class GridViewUI extends StatelessWidget {
  final List<Media> mediaList;

  GridViewUI({required this.mediaList});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.0,
      ),
      itemCount: mediaList.length,
      itemBuilder: (BuildContext context, int index) {
        return GridItem(media: mediaList[index]);
      },
    );
  }
}

class GridItem extends StatelessWidget {
  final Media media;
  final int maxNameLength;
  const GridItem({Key? key, required this.media,  this.maxNameLength = 20}) : super(key: key);

   String getShortenedName(String name) {
    if (name.length <= maxNameLength) {
      return name;
    } else {
      return name.substring(0, maxNameLength) + '...';
    }
  }

 String getFileType() {
    // Extract file extension from mediaType
    String mediaType = media.mediaType.toLowerCase();

    // Map file extensions to corresponding types
    Map<String, String> fileTypes = {
      'jpg' : 'image',
      'image': 'image',
      'pdf': 'pdf',
      'doc': 'word',
      'docx': 'word',
      'xls': 'excel',
      'xlsx': 'excel',
      'ppt': 'powerpoint',
      'pptx': 'powerpoint',
      'video': 'video',
    };

    // Return corresponding file type
    return fileTypes.containsKey(mediaType) ? fileTypes[mediaType]! : 'other';
  }
Future<String> getThumbnailUrl() async {
  String fileType = getFileType();
  print('File type: $fileType'); 
  if (fileType == 'image') {
    // Await the result of getImageUrl() since it's asynchronous
    print('Media ID: ${media.mediaId}'); 
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
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return MediaDetailsDialog(media: media);
          },
        );
      },
      child: FutureBuilder<String>(
        future: getThumbnailUrl(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
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
                          ? Image.network(
                              "https://magic-sign.cloud/v_ar/web/MSlibrary/${media.storedAs}",
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
                      getShortenedName(media.name), 
                      textAlign: TextAlign.center,
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis, 
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
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