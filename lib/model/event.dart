class EventResponse {
  final List<Event> records;

  EventResponse({required this.records});

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(
      records: (json['records'] as List)
          .map((record) => Event.fromJson(record))
          .toList(),
    );
  }
}

class Event {
  final dynamic eventID;
  final dynamic eventTypeId;
  final dynamic campaignID;
  final dynamic userID;
  final dynamic isPriority;
  final dynamic fromDT;
  final dynamic toDT;
  final dynamic displayOrder;
  final dynamic displayGroupID;
  final dynamic dayPartId;

  Event({
    required this.eventID,
    required this.eventTypeId,
    required this.campaignID,
    required this.userID,
    required this.isPriority,
    required this.fromDT,
    required this.toDT,
    required this.displayOrder,
    required this.displayGroupID,
    required this.dayPartId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventID: json['eventID'],
      eventTypeId: json['eventTypeId'],
      campaignID: json['CampaignID'], // Notice the capitalization difference
      userID: json['userID'],
      isPriority: json['is_priority'],
      fromDT: json['FromDT'],
      toDT: json['ToDT'],
      displayOrder: json['DisplayOrder'],
      displayGroupID: json['DisplayGroupID'],
      dayPartId: json['dayPartId'],
    );
  }
}
