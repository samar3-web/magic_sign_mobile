import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/controller/playlistController.dart';
import 'package:magic_sign_mobile/model/Zone.dart';
import 'package:magic_sign_mobile/screens/playlist/zoneWidget.dart';

class PreviewScreen extends StatefulWidget {
  final int layoutId;
  const PreviewScreen({Key? key, required this.layoutId}) : super(key: key);
  static const String routeName = 'PreviewScreen';

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final PlaylistController playlistController = Get.put(PlaylistController());
  late Future<Map<String, List<Zone>>> futureZones;

  @override
  void initState() {
    super.initState();
    futureZones = playlistController.fetchZones(widget.layoutId);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zones Display'),
      ),
      body: Container(
        width: Get.width,
        height: Get.height,
        child: Center(
          child: FutureBuilder<Map<String, List<Zone>>>(
            future: futureZones,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height,
                  child: Stack(
                    children: snapshot.data!.entries.expand((entry) {
                      return entry.value.map((zone) {
                        return ZoneWidget(
                          left: zone.left,
                          width: zone.width,
                          layoutId: widget.layoutId,
                          top: double.parse(zone.top.toString()),
                          zoneId: zone.zoneId,
                        );
                      }).toList();
                    }).toList(),
                  ),
                );
              } else {
                return Center(child: Text("No zones data available"));
              }
            },
          ),
        ),
      ),
    );
  }
}
