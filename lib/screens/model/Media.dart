class Media {
  final int mediaId;
  final int ownerId;
  final String name;
  final String mediaType;
  Media._({required this.mediaId, required this.ownerId, required this.mediaType, required this.name});

  factory Media.fromJson(Map<String, dynamic> json) => Media._(
      mediaId: json['mediaId'],
      ownerId: json['ownerId'],
      name: json['name'],
      mediaType: json['mediaType']);
}
