import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_sign_mobile/controller/playlistController.dart';
import 'package:magic_sign_mobile/model/Zone.dart';

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
      body: FutureBuilder<Map<String, List<Zone>>>(
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
                    return Positioned(
                      left: calculLeft(zone.left),
                      top: double.parse(zone.top.toString()),
                      child: Container(
                        width: double.parse(zone.width.toString()),
                        height: double.parse(zone.height.toString()),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            'Zone ID: ${entry.key}',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),
            );
          } else {
            return Center(child: Text("No zones data available"));
          }
        },
      ),
    );
  }

 double calculLeft(double left) {
    switch (left) {
      case > 1440:
        return Get.width * 0.75; // Left
      case > 960:
        return Get.width * 0.5;
      case > 480:
        return Get.width * 0.25;
      default:
        return 0;
    }
  }
}
