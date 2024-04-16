import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_sign_mobile/model/Playlists.dart';
import 'package:magic_sign_mobile/model/Timeline.dart';

import '../../model/Regions.dart';

class PreviewScreen extends StatefulWidget {
  final Timeline timeline; 

  const PreviewScreen({Key? key, required this.timeline}) : super(key: key); 

  static const String routeName = 'PreviewScreen';

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timeline'),
      ),
      body: ListView.builder(
        itemCount: widget.timeline.regions?.length, // Access the timeline data using widget.timeline
        itemBuilder: (context, index) {
          Regions region = widget.timeline.regions![index];
          return Container(
            width: double.parse(region.width!),
            height: double.parse(region.height!),
            margin: EdgeInsets.fromLTRB(
              double.parse(region.left!),
              double.parse(region.top!),
              0.0,
              0.0,
            ),
            child: ListView.builder(
              itemCount: region.playlists?.length,
              itemBuilder: (context, playlistIndex) {
                Playlists playlist = region.playlists![playlistIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: playlist.widgets!.map((widget) {
                    switch (widget.type) {
                      case 'pdf':
                        return Text('PDF Widget with ID: ${widget.widgetId}');
                      case 'image':
                        return Text('Image Widget with ID: ${widget.widgetId}');
                      case 'webpage':
                        return Text('Webpage Widget with ID: ${widget.widgetId}');
                      default:
                        return Text('Unknown Widget Type');
                    }
                  }).toList(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
