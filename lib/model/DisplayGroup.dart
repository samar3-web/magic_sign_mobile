class DisplayGroup {
  int? displayGroupId;
  String? displayGroup;
  int? isDisplaySpecific;
  int? isDynamic;
  int? userId;

  DisplayGroup(
      {this.displayGroupId,
      this.displayGroup,
      this.isDisplaySpecific,
      this.isDynamic,
      this.userId,
      });

  DisplayGroup.fromJson(Map<String, dynamic> json) {
    displayGroupId = json['displayGroupId'];
    displayGroup = json['displayGroup'];
    isDisplaySpecific = json['isDisplaySpecific'];
    isDynamic = json['isDynamic'];
    userId = json['userId'];
  }

}
