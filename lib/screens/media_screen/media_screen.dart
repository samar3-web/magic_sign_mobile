import 'dart:io';

import 'package:cached_network_image_builder/cached_network_image_builder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/controller/mediaController.dart';
import 'package:magic_sign_mobile/screens/media_screen/media_details_dialog.dart';
import 'package:magic_sign_mobile/model/Media.dart';
import 'package:magic_sign_mobile/widgets/BaseScreen.dart';
import 'package:shimmer/shimmer.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({Key? key}) : super(key: key);
  static const String routeName = 'MediaScreen';

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  late MediaController mediaController;
  final ScrollController _scrollController = ScrollController();
  bool isloading = false;

  Future<void> _refreshMedia() async {
    await mediaController.getMedia();
  }

  @override
  void initState() {
    super.initState();
    mediaController = Get.put(MediaController());
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {}
    });
  }

  Future<void> fetchdata() async {
    await Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          mediaController.getMedia();
          isloading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    mediaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Media Screen',
      body: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Call function to select and upload files
            List<File> pickedFiles = await _selectFiles();
            if (pickedFiles.isNotEmpty) {
              mediaController.uploadFiles(context, pickedFiles);
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          style: TextStyle(fontSize: 16.0),
                          decoration: InputDecoration(
                            hintText: 'Rechercher',
                            hintStyle: TextStyle(color: boxColor),
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: kSecondaryColor,
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                            contentPadding: EdgeInsets.all(12.0),
                          ),
                          onChanged: (value) {
                            mediaController.searchMedia(value);
                          },
                        ),
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
                        if (newValue != null) {
                          setState(() {
                            mediaController.filterByType(newValue);
                          });
                        }
                      },
                      items: <String>[
                        'Image',
                        'PDF',
                        'Word',
                        'Excel',
                        'PowerPoint',
                        'Video'
                      ].map<DropdownMenuItem<String>>((String value) {
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
                        if (newValue != null) {
                          setState(() {
                            mediaController.filterByOwner(newValue);
                          });
                        }
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
              Obx( () =>
                 Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: mediaController.mediaList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GridItem(media: mediaController.mediaList[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
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
  final ScrollController controller;

  GridViewUI({required this.mediaList, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller,
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

  const GridItem({Key? key, required this.media, this.maxNameLength = 20})
      : super(key: key);

  String getShortenedName(String name) {
    if (name.length <= maxNameLength) {
      return name;
    } else {
      return name.substring(0, maxNameLength) + '...';
    }
  }

  String getFileType() {
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

  Future<String> getThumbnailUrl() async {
    String fileType = getFileType();
    print('File type: $fileType');
    try {
      if (fileType == 'image') {
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
    } catch (e) {
      print('Error loading image: $e');
      return 'assets/images/default.png';
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
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            );
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
                          ? CachedNetworkImageBuilder(
                              url:
                                  "https://magic-sign.cloud/v_ar/web/MSlibrary/${media.storedAs}",
                              builder: (image) {
                                return Center(child: Image.file(image));
                              },
                              placeHolder: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  color: Colors.white,
                                ),
                              ),
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
