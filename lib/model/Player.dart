class Player {
  int? displayId;
  String? display;
  String? clientAddress;
  int? lastAccessed;
  int? loggedIn;
  int? licensed;
  String? defaultLayout;
  int? displayGroupId;
  Player({
    this.displayId,
    this.display,
    this.clientAddress,
    this.lastAccessed,
    this.loggedIn,
    this.licensed,
    this.defaultLayout,
   this.displayGroupId,
  });

  Player.fromJson(Map<String, dynamic> json) {
    displayId = json['displayId'];
    display = json['display'] as String?;
    clientAddress = json['clientAddress'];
    lastAccessed = json['lastAccessed'];
    loggedIn = json['loggedIn'];
    licensed = json['licensed'];
    defaultLayout = json['defaultLayout'];
    displayGroupId = json['displayGroupId'];
  }
}
