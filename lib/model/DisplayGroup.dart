class DisplayGroup {
  int? displayGroupId;
  String? displayGroup;
  Null? description;
  int? isDisplaySpecific;
  int? isDynamic;
  Null? dynamicCriteria;
  int? userId;
  Null? tags;

  DisplayGroup(
      {this.displayGroupId,
      this.displayGroup,
      this.description,
      this.isDisplaySpecific,
      this.isDynamic,
      this.dynamicCriteria,
      this.userId,
      this.tags});

  DisplayGroup.fromJson(Map<String, dynamic> json) {
    displayGroupId = json['displayGroupId'];
    displayGroup = json['displayGroup'];
    description = json['description'];
    isDisplaySpecific = json['isDisplaySpecific'];
    isDynamic = json['isDynamic'];
    dynamicCriteria = json['dynamicCriteria'];
    userId = json['userId'];
    tags = json['tags'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['displayGroupId'] = this.displayGroupId;
    data['displayGroup'] = this.displayGroup;
    data['description'] = this.description;
    data['isDisplaySpecific'] = this.isDisplaySpecific;
    data['isDynamic'] = this.isDynamic;
    data['dynamicCriteria'] = this.dynamicCriteria;
    data['userId'] = this.userId;
    data['tags'] = this.tags;
    return data;
  }
}
