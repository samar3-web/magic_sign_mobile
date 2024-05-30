import 'dart:convert';

class Media {
  final int mediaId;
  final int ownerId;
  final String name;
  final String mediaType;
  final String storedAs;
  final String duration;
  final String owner;
  final String retired;
  final String createdDt;
  final String fileSize;

  Media._({
    required this.mediaId,
    required this.ownerId,
    required this.mediaType,
    required this.name,
    required this.storedAs,
    required this.duration,
    required this.owner,
    required this.retired,
    required this.createdDt,
    required this.fileSize,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    int parsedMediaId = int.tryParse(json['mediaId'].toString()) ?? -1;
    int parsedOwnerId = int.tryParse(json['ownerId'].toString()) ?? -1;

    return Media._(
      mediaId: parsedMediaId,
      ownerId: parsedOwnerId,
      name: json['name'] ?? 'Unknown',
      mediaType: json['mediaType'] ?? 'Unknown Type',
      storedAs: json['storedAs'] ?? 'Not Available',
      duration: json['duration']?.toString() ?? '0',
      owner: json['owner'] ?? 'No Owner',
      retired: json['retired']?.toString() ?? 'false',
      createdDt: json['createdDt'] ?? 'Unknown',
      fileSize: json['fileSize']?.toString() ?? '0',
    );
  }
}

List<Media> parseMediaItems(String jsonResponse) {
  final parsed = json.decode(jsonResponse).cast<Map<String, dynamic>>();
  return parsed.map<Media>((json) => Media.fromJson(json)).toList();
}

Map<String, int> calculateMediaSizes(List<Media> mediaItems) {
  Map<String, int> mediaSizes = {
    'video': 0,
    'pdf': 0,
    'image': 0,
    'font': 0,
    'module': 0,
  };

  for (var item in mediaItems) {
    if (mediaSizes.containsKey(item.mediaType)) {
      int fileSize = int.tryParse(item.fileSize) ?? 0;
      mediaSizes[item.mediaType] = mediaSizes[item.mediaType]! + fileSize;
    }
  }

  return mediaSizes;
}
