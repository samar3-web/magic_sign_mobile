import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WidgetData {
   int? widgetId;
   int? playlistId;
   String? type;
   int? duration;
   String? displayOrder;

  WidgetData({
    required this.widgetId,
    required this.playlistId,
    required this.type,
    required this.duration,
    required this.displayOrder,
  });
  WidgetData.fromJson(Map<String, dynamic> json) {
    widgetId = json['widgetId'];
    playlistId = json['playlistId'];
    type = json['type'];
    duration = json['duration'];
    displayOrder = json['displayOrder'];
 
  

  }

}