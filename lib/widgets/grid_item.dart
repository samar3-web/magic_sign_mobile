import 'package:cached_network_image_builder/cached_network_image_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/model/Media.dart';
import 'package:magic_sign_mobile/screens/media_screen/media_details_dialog.dart';

class GridItem extends StatelessWidget {
  final Media media;
  final Function(Media) onDoubleTap;

  GridItem({required this.media, required this.onDoubleTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => MediaDetailsDialog(media: media),
        );
      },
      onDoubleTap: () {
        onDoubleTap(media);
      },
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: CachedNetworkImageBuilder(
              url:
                  "https://magic-sign.cloud/v_ar/web/MSlibrary/${media.storedAs}",
              builder: (image) {
                return Center(child: Image.file(image));
              },
            )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                media.name,
                style: TextStyle(fontSize: 16.0),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
