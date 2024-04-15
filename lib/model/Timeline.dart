import 'package:magic_sign_mobile/model/Regions.dart';

class Timeline {
  int? layoutId;
  int? ownerId;
  int? campaignId;
  Null? backgroundImageId;
  int? schemaVersion;
  String? layout;
  Null? description;
  String? backgroundColor;
  String? createdDt;
  String? modifiedDt;
  int? status;
  int? retired;
  int? backgroundzIndex;
  int? width;
  int? height;
  Null? displayOrder;
  int? duration;
  Null? statusMessage;
  List<Regions>? regions;
  String? owner;
  Null? groupsWithPermissions;

  Timeline(
      {this.layoutId,
      this.ownerId,
      this.campaignId,
      this.backgroundImageId,
      this.schemaVersion,
      this.layout,
      this.description,
      this.backgroundColor,
      this.createdDt,
      this.modifiedDt,
      this.status,
      this.retired,
      this.backgroundzIndex,
      this.width,
      this.height,
      this.displayOrder,
      this.duration,
      this.statusMessage,
      this.regions,
      this.owner,
      this.groupsWithPermissions});

  Timeline.fromJson(Map<String, dynamic> json) {
    layoutId = json['layoutId'];
    ownerId = json['ownerId'];
    campaignId = json['campaignId'];
    backgroundImageId = json['backgroundImageId'];
    schemaVersion = json['schemaVersion'];
    layout = json['layout'];
    description = json['description'];
    backgroundColor = json['backgroundColor'];
    createdDt = json['createdDt'];
    modifiedDt = json['modifiedDt'];
    status = json['status'];
    retired = json['retired'];
    backgroundzIndex = json['backgroundzIndex'];
    width = json['width'];
    height = json['height'];
    displayOrder = json['displayOrder'];
    duration = json['duration'];
    statusMessage = json['statusMessage'];
    if (json['regions'] != null) {
      regions = <Regions>[];
      json['regions'].forEach((v) {
        regions!.add(new Regions.fromJson(v));
      });
    }
   
  
   
    owner = json['owner'];
    groupsWithPermissions = json['groupsWithPermissions'];
  }


}



