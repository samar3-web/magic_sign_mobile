import 'package:magic_sign_mobile/model/Playlist.dart';
import 'package:magic_sign_mobile/model/Playlists.dart';
import 'package:magic_sign_mobile/model/Timeline.dart';

class Regions {
  int? regionId;
  int? layoutId;
  int? ownerId;
  String? name;
  String? width;
  String? height;
  String? top;
  String? left;
  int? zIndex;
  List<Playlists>? playlists;
  Null? displayOrder;
  int? duration;
  Null? tempId;

  Regions(
      {this.regionId,
      this.layoutId,
      this.ownerId,
      this.name,
      this.width,
      this.height,
      this.top,
      this.left,
      this.zIndex,
      this.playlists,
      
      this.displayOrder,
      this.duration,
      this.tempId});

  Regions.fromJson(Map<String, dynamic> json) {
    regionId = json['regionId'];
    layoutId = json['layoutId'];
    ownerId = json['ownerId'];
    name = json['name'];
    width = json['width'];
    height = json['height'];
    top = json['top'];
    left = json['left'];
    zIndex = json['zIndex'];
    if (json['playlists'] != null) {
      playlists = <Playlists>[];
      json['playlists'].forEach((v) {
        playlists!.add(new Playlists.fromJson(v));
      });
    }
   
   
    displayOrder = json['displayOrder'];
    duration = json['duration'];
    tempId = json['tempId'];
  }

  
}
