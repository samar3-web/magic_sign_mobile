class PlaylistRessource {
    int? widgetId;
    int? playlistId;
    int? ownerId;
    String? type;
    int? duration;
    String? displayOrder;
    String? useDuration;
    String? calculatedDuration;
    int? createdDt;
    int? modifiedDt;
    List<String>? mediaIds;
    String? playlist;
    dynamic tempId;
    bool? isNew;
    String? name;
    String? transition;

    PlaylistRessource({
        required this.widgetId,
        required this.playlistId,
        required this.ownerId,
        required this.type,
        required this.duration,
        required this.displayOrder,
        required this.useDuration,
        required this.calculatedDuration,
        required this.createdDt,
        required this.modifiedDt,
        required this.mediaIds,
        required this.playlist,
        required this.tempId,
        required this.isNew,
        required this.name,
        required this.transition,
    });
    PlaylistRessource.fromJson(Map<String, dynamic> json) {
    widgetId = json['widgetId'];
    playlistId = json['playlistId'];
    ownerId = json['ownerId'];
    type = json['type'];
    duration = json['duration'];
    displayOrder = json['displayOrder'];
    useDuration = json['useDuration'];
    calculatedDuration = json['calculatedDuration'];
    createdDt = json['createdDt'];
    modifiedDt = json['modifiedDt'];
    
    mediaIds = json['mediaIds'].cast<String>();
   
    playlist = json['playlist'];
    tempId = json['tempId'];
    isNew = json['isNew'];
    name = json['name'];
    transition = json['transition'];
  }


}
