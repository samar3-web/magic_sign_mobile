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
      body: Container()
    );
  }
}
