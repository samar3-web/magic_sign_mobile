import 'package:magic_sign_mobile/screens/model/Widget.dart';

class Playlists {
  int? playlistId;
  int? ownerId;
  String? name;
  List<WidgetData>? widgets;
  String? displayOrder;

  Playlists(
      {this.playlistId,
      this.ownerId,
      this.name,
      this.widgets,
      this.displayOrder});

  Playlists.fromJson(Map<String, dynamic> json) {
    playlistId = json['playlistId'];
    ownerId = json['ownerId'];
    name = json['name'];
   
    if (json['widgets'] != null) {
      widgets = <WidgetData>[];
      json['widgets'].forEach((v) {
        widgets!.add( WidgetData.fromJson(v));
      });
    }
   
    displayOrder = json['displayOrder'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['playlistId'] = this.playlistId;
    data['ownerId'] = this.ownerId;
    data['name'] = this.name;
 
   
    data['displayOrder'] = this.displayOrder;
    return data;
  }
}