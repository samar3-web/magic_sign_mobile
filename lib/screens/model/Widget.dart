import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WidgetData {
  int? widgetId;
  int? playlistId;
  String? type;
  int? duration;
  String? displayOrder;
  List<String>? mediaIds;

  WidgetData({
    required this.widgetId,
    required this.playlistId,
    required this.type,
    required this.duration,
    required this.displayOrder,
    required this.mediaIds,
  });
  WidgetData.fromJson(Map<String, dynamic> json) {
    widgetId = json['widgetId'];
    playlistId = json['playlistId'];
    type = json['type'];
    duration = json['duration'];
    displayOrder = json['displayOrder'];
    mediaIds = json['mediaIds'] != null ? List<String>.from(json['mediaIds'] as List<dynamic>) : null; 
  }
}
