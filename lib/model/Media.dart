class Media {
  final int mediaId;
  final int ownerId;
  final String name;
  final String mediaType;
  final String storedAs;
  final String duration;
  final String owner;
  final String retired;
  Media._({
    required this.mediaId,
    required this.ownerId,
    required this.mediaType,
    required this.name,
    required this.storedAs,
    required this.duration,
    required this.owner,
    required this.retired,
  });

    factory Media.fromJson(Map<String, dynamic> json) {
    // Using int.tryParse to convert string to int safely and providing a fallback value (-1)
    int parsedMediaId = int.tryParse(json['mediaId'].toString()) ?? -1;
    int parsedOwnerId = int.tryParse(json['ownerId'].toString()) ?? -1;

    return Media._(
      mediaId: parsedMediaId,
      ownerId: parsedOwnerId,
      name: json['name'] ?? 'Unknown', // Providing a default value if null
      mediaType: json['mediaType'] ?? 'Unknown Type', // Default if null
      storedAs: json['storedAs'] ?? 'Not Available', // Default if null
      duration: json['duration']?.toString() ?? '0', // Default to '0' if null
      owner: json['owner'] ?? 'No Owner', // Default if null
      retired: json['retired']?.toString() ?? 'false', // Default to 'false' if null
    );
  }
}
