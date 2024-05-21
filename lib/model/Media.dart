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
    );
  }
}
