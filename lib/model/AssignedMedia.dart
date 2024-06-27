import 'dart:convert';

class AssignedMedia {
  final int mediaID;
  final String name;
  final String type;
  final String duration;
  final String storedAs;

  AssignedMedia(
      this.mediaID, this.name, this.type, this.duration, this.storedAs);

  AssignedMedia._({
    required this.mediaID,
    required this.type,
    required this.name,
    required this.duration,
    required this.storedAs,
  });

  factory AssignedMedia.fromJson(Map<String, dynamic> json) {
    return AssignedMedia._(
      mediaID: int.tryParse(json['mediaID']?.toString() ?? '-1') ?? -1,
      name: json['name'] ?? 'Unknown',
      type: json['type'] ?? 'Unknown Type',
      duration: json['duration']?.toString() ?? '0',
      storedAs: json['storedAs'] ?? 'Not Available',
    );
  }
}
