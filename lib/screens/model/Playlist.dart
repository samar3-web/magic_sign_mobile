class Playlist {
  final int layoutId;
  final String layout;
  final String status;
  final String duration;
  final String owner;

  Playlist._({
    required this.layoutId,
    required this.layout,
    required this.status,
    required this.duration,
    required  this.owner,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist._(
        layoutId: json['layoutId'],
        layout: json['layout'],
        status: json['status'].toString(),
        duration: json['duration'].toString(),
        owner: json['owner'] as String? ?? 'Unknown Owner',
      );
}
