import 'package:magic_sign_mobile/model/Media.dart';

class Timeline {
  final int timelineId;
  final List<Media> mediaList;

  Timeline({required this.timelineId, required this.mediaList});

  factory Timeline.fromJson(int id, List<dynamic> jsonList) {
  List<Media> media = jsonList.map((item) => Media.fromJson(item)).toList();
  return Timeline(timelineId: id, mediaList: media);
}
}