class Media {
  final int mediaId;
  final int ownerId;
  final String name;
  final String mediaType;
  final String storedAs;
  Media._(
      {required this.mediaId,
      required this.ownerId,
      required this.mediaType,
      required this.name,
      required this.storedAs});

  factory Media.fromJson(Map<String, dynamic> json) => Media._(
      mediaId: json['mediaId'],
      ownerId: json['ownerId'],
      name: json['name'],
      mediaType: json['mediaType'],
      storedAs: json['storedAs']);
}
