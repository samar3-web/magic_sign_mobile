class Player {
  int? displayId;
  String? display;
  String? clientAddress;
  int? lastAccessed;
  int? loggedIn;
  int? licensed;
  Player({
    this.displayId,
    this.display,
    this.clientAddress,
    this.lastAccessed,
    this.loggedIn,
    this.licensed,
  });

  Player.fromJson(Map<String, dynamic> json) {
    displayId = json['displayId'];
    display = json['display'] as String?;
    clientAddress = json['clientAddress'];
    lastAccessed = json['lastAccessed'];
    loggedIn = json['loggedIn'];
    licensed = json['licensed'];
  }
}
