import 'package:flutter/material.dart';
import 'package:magic_sign_mobile/constants.dart';
import 'package:magic_sign_mobile/model/Zone.dart';

class PositioningAlertDialog {
  static void show(BuildContext context, Map<String, List<Zone>> zones) {
    // Print the zones data to the console for debugging
    zones.forEach((key, zoneList) {
      print('Zone ID: $key');
      zoneList.forEach((zone) {
        print(
            'Zone Details - Left: ${zone.left}, Top: ${zone.top}, Width: ${zone.width}, Height: ${zone.height}');
      });
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Zones Display'),
          content: Container(
            width: MediaQuery.of(context).size.width / 4,
            height: MediaQuery.of(context).size.height / 4,
            child: Stack(
              children: zones.entries.expand((entry) {
                int zoneIndex = 0; // Initialize a zone index counter
                return entry.value.map((zone) {
                  zoneIndex++; // Increment the zone index for each zone
                  return Positioned(
                    left: _calculateLeft(context, zone.left),
                    top: double.parse(zone.top.toString()),
                    child: Container(
                      width: double.parse(zone.width.toString()),
                      height: double.parse(zone.height.toString()),
                      decoration: BoxDecoration(
                        border: Border.all(color: kSecondaryColor, width: 2),
                      ),
                      child: SizedBox(
                        child: Center(
                          child: Container(
                            color: Colors
                                .black54, // Added background color to text container
                            child: Text(
                              'Zone ${zoneIndex}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  backgroundColor: Colors
                                      .black54 // Ensure text has background
                                  ),
                              textAlign: TextAlign.start, // Center align text
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList();
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static double _calculateLeft(BuildContext context, double left) {
    if (left > 1440) {
      return MediaQuery.of(context).size.width * 0.75;
    } else if (left > 960) {
      return MediaQuery.of(context).size.width * 0.33;
    } else if (left > 480) {
      return MediaQuery.of(context).size.width * 0.25;
    } else {
      return 0;
    }
  }
}
