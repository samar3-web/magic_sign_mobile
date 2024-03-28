import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/screens/model/Playlist.dart';
import 'package:magic_sign_mobile/screens/playlist/playlistController.dart';
import 'package:magic_sign_mobile/screens/playlist/playlist_details.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);
  static const String routeName = 'PlaylistScreen';

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final PlaylistController playlistController = Get.put(PlaylistController());

  @override
  void initState() {
    super.initState();
    // Call the method to fetch playlist data when the widget is initialized
    playlistController.getPlaylist();
  }

  String formatDuration(String durationString) {
    int duration = int.tryParse(durationString) ?? 0;
    int hours = duration ~/ 3600;
    int minutes = (duration % 3600) ~/ 60;
    int seconds = duration % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _navigateToDetailScreen(Playlist playlist) {
    Get.to(() => PlaylistDetail(playlist: playlist), arguments: playlist);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playlist'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
        },
        backgroundColor: kSecondaryColor,
        child: Icon(Icons.add),
      ),
      body: Center(
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
                        //mediaController.searchMedia(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                    () => playlistController.playlistList.isEmpty
                    ? Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  ),
                ) // Show centered loading indicator while data is loading
                    : ListView.builder(
                  itemCount: playlistController.playlistList.length,
                  itemBuilder: (context, index) {
                    Playlist playlist = playlistController.playlistList[index];
                    Color statusColor = playlist.status == '3' ? Colors.green : playlist.status == '2' ? Colors.orange : Colors.transparent;

                    return GestureDetector(
                      onTap: () => _navigateToDetailScreen(playlist),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Layout: ${playlist.layout}',
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Duration: ${formatDuration(playlist.duration)}',
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Owner: ${playlist.owner}',
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Status : ',
                                      style: Theme.of(context).textTheme.bodyText2,
                                    ),
                                    SizedBox(width: 4),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_drop_down),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}