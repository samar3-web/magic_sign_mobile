import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/controller/playlistController.dart';
import 'package:magic_sign_mobile/model/Playlist.dart';

class PlaylistPopup extends StatelessWidget {
  final PlaylistController controller = Get.put(PlaylistController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AlertDialog(
        title: Text('Select Playlist'),
        content: controller.selectedPlaylist.value.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(hintText: 'Search Playlists'),
                    onChanged: (value) {
                      controller.searchPlaylist(value);
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.playlistList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(controller.playlistList[index].layout),
                          onTap: () {
                            controller.selectedPlaylist.value = controller.playlistList[index].layout;
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              )
            : DropdownButton<String>(
                value: controller.selectedPlaylist.value,
                items: controller.playlistList.map((Playlist playlist) {
                  return DropdownMenuItem<String>(
                    value: playlist.layout,
                    child: Text(playlist.layout),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  controller.selectedPlaylist.value = newValue!;
                },
              ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      );
    });
  }
}
