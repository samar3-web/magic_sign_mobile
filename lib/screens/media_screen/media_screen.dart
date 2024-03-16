import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/screens/media_screen/mediaController.dart';
import 'package:magic_sign_mobile/screens/model/Media.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({Key? key}) : super(key: key);
  static const String routeName = 'MediaScreen';

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  final MediaController mediaController = Get.put(MediaController());

  @override
  void initState() {
    super.initState();
    // Fetch media data when the screen initializes
    mediaController.getMedia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Media Screen'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle add button tap
        },
        backgroundColor: kSecondaryColor,
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
             child: Row(
              children: [
                Expanded(
                  child: TextField(
                    //controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: boxColor),
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    
                    ),
                    onChanged: (value) {
                     // mediaController.search(value);
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
                  //value: selectedType,
                  onChanged: (String? newValue) {
                    setState(() {
                      //selectedType = newValue!;
                      //mediaController.filterByType(selectedType);
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
                  //value: selectedProperty,
                  onChanged: (String? newValue) {
                    setState(() {
                      //selectedProperty = newValue!;
                     // mediaController.filterByProperty(selectedProperty);
                    });
                  },
                  items: <String>['Property A', 'Property B', 'Property C']
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
    );
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

  const GridItem({Key? key, required this.media}) : super(key: key);

 String getFileType() {
    // Extract file extension from mediaType
    String mediaType = media.mediaType.toLowerCase();

    // Map file extensions to corresponding types
    Map<String, String> fileTypes = {
      'image': 'image',
      'pdf': 'pdf',
      'doc': 'word',
      'docx': 'word',
      'xls': 'excel',
      'xlsx': 'excel',
      'ppt': 'powerpoint',
      'pptx': 'powerpoint',
      'video': 'video',
      // Add more file extensions and types as needed
    };

    // Return corresponding file type
    return fileTypes.containsKey(mediaType) ? fileTypes[mediaType]! : 'other';
  }
Future<String> getThumbnailUrl() async {
  String fileType = getFileType();
  print('File type: $fileType'); // Add this line to check the value of fileType
  if (fileType == 'image') {
    // Await the result of getImageUrl() since it's asynchronous
    print('Media ID: ${media.mediaId}'); // Add this line to check the media ID
    return await MediaController().getImageUrl(media.storedAs);
  } else {
    switch (fileType) {
      case 'word':
        return 'assets/images/word-logo.png'; // Change to the path of your word logo image
      case 'pdf':
        return 'assets/images/pdf-logo.png'; // Change to the path of your pdf logo image
      case 'excel':
        return 'assets/images/excel-logo.png'; // Change to the path of your excel logo image
      case 'powerpoint':
        return 'assets/images/pp-logo.png'; // Change to the path of your powerpoint logo image
      case 'video':
        return 'assets/images/video-logo.png'; // Change to the path of your video logo image
      default:
        return 'assets/images/default.png'; // Change to the path of your default logo image
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
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
            child: Center(
              child: getFileType() == 'image'
                  ? Image.network(
                      "https://magic-sign.cloud/v_ar/web/MSlibrary/${media.storedAs}",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Image.asset(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
            ),
          );
        }
      },
    );
  }
}