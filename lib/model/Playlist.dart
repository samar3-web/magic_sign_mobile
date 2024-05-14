import 'package:flutter/material.dart';

class Playlist {
  final int layoutId;
  final int campaignId;
  final String layout;
  final String status;
  final String duration;
  final String owner;
  final int playlistId;
  final List<Region> regions;

  Playlist({
    required this.layoutId,
    required this.campaignId,
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
      campaignId: json['campaignId'] ?? 0,
      layout: json['layout'] ?? 'Unknown Layout',
      status: json['status'].toString(),
      duration: json['duration']?.toString() ?? 'Unknown Duration',
      owner: json['owner']?.toString() ?? 'Unknown Owner',
      playlistId: json['playlistId'] ?? 0,
      regions: (json['regions'] as List<dynamic>?)?.map((regionJson) {
            return Region.fromJson(regionJson);
          }).toList() ??
          [],
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
      regionId: json['regionId'] ?? 0,
      name: json['name'] ?? 'Unknown Region',
      playlists: (json['playlists'] as List<dynamic>?)
              ?.map((playlistJson) => PlaylistInRegion.fromJson(playlistJson))
              .toList() ??
          [],
    );
  }
}

class PlaylistInRegion {
  final int playlistId;
  final String name;
  List<Map<String, dynamic>> widgets;

  PlaylistInRegion(
      {required this.playlistId, required this.name, required this.widgets});

  factory PlaylistInRegion.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> parsedWidgets =
        List<Map<String, dynamic>>.from(json['widgets']);
    return PlaylistInRegion(
      playlistId: json['playlistId'] ?? 0,
      name: json['name'] ?? 'Unknown Playlist',
      widgets: parsedWidgets,
    );
  }
}
