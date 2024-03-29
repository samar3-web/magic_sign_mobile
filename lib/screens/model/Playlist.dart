import 'package:flutter/material.dart';

class Playlist {
  final int layoutId;
  final String layout;
  final String status;
  final String duration;
  final String owner;
  final int playlistId;
  final List<Region> regions;

  Playlist({
    required this.layoutId,
    required this.layout,
    required this.status,
    required this.duration,
    required this.owner,
    required this.playlistId,
    required this.regions,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      layoutId: json['layoutId'] ?? 0, 
      layout: json['layout'] ?? 'Unknown Layout', 
      status: json['status'].toString(),
      duration: json['duration']?.toString() ?? 'Unknown Duration', 
      owner: json['owner'] as String? ?? 'Unknown Owner',
      playlistId: json['playlistId'] ?? 0, 
      regions: (json['regions'] as List<dynamic>)
          .map((regionJson) => Region.fromJson(regionJson))
          .toList(),
    );
  }
}


class Region {
  final int regionId;
  final String name;
  final List<PlaylistInRegion> playlists;

  Region({
    required this.regionId,
    required this.name,
    required this.playlists,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      regionId: json['regionId'],
      name: json['name'],
      playlists: (json['playlists'] as List<dynamic>)
          .map((playlistJson) => PlaylistInRegion.fromJson(playlistJson))
          .toList(),
    );
  }
}

class PlaylistInRegion {
  final int playlistId;
  final String name;

  PlaylistInRegion({
    required this.playlistId,
    required this.name,
  });

  factory PlaylistInRegion.fromJson(Map<String, dynamic> json) {
    return PlaylistInRegion(
      playlistId: json['playlistId'],
      name: json['name'],
    );
  }
}