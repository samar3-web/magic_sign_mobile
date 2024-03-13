import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/screens/media_screen/mediaController.dart';

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
      body: Obx(
        () => mediaController.isLoading.value
            ? Center(
                child: CircularProgressIndicator(),
              )
            : GridViewUI(),
      ),
    );
  }
}

class GridViewUI extends StatelessWidget {
  final List<String> items = List.generate(20, (index) => 'Item $index');

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.0, // Adjust this ratio for item size
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return GridItem(item: items[index]);
      },
    );
  }
}

class GridItem extends StatelessWidget {
  final String item;

  const GridItem({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        child: Text(
          item,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
