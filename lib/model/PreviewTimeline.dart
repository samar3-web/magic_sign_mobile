import 'package:magic_sign_mobile/model/AssignedMedia.dart';

class PreviewTimeline {
  final int timelineId;
  final List<AssignedMedia> mediaList;

  PreviewTimeline({required this.timelineId, required this.mediaList});

  factory PreviewTimeline.fromJson(int id, List<dynamic> jsonList) {
  List<AssignedMedia> assignedMedia = jsonList.map((item) => AssignedMedia.fromJson(item)).toList();
  return PreviewTimeline(timelineId: id, mediaList: assignedMedia);
}
}