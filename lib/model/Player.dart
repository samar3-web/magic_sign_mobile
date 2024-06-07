class Player {
  int? displayId;
  String? display;
  String? clientAddress;
  int? lastAccessed;
  int? loggedIn;
  int? licensed;
  String? defaultLayout;
  int? displayGroupId;
  int? defaultLayoutId;
  String? license;
  int? incSchedule;
  int? emailAlert;
  int? wakeOnLanEnabled;
  Player(
      {this.displayId,
      this.display,
      this.clientAddress,
      this.lastAccessed,
      this.loggedIn,
      this.licensed,
      this.defaultLayout,
      this.displayGroupId,
      this.defaultLayoutId,
      this.license,
      this.incSchedule,
      this.emailAlert,
      this.wakeOnLanEnabled});

  Player.fromJson(Map<String, dynamic> json) {
    displayId = json['displayId'];
    display = json['display'] as String?;
    clientAddress = json['clientAddress'];
    lastAccessed = json['lastAccessed'];
    loggedIn = json['loggedIn'];
    licensed = json['licensed'];
    defaultLayout = json['defaultLayout'];
    displayGroupId = json['displayGroupId'];
    defaultLayoutId = json['defaultLayoutId'];
    license = json['license'];
    incSchedule = json['incSchedule'];
    emailAlert = json['emailAlert'];
    wakeOnLanEnabled = json['wakeOnLanEnabled'];
  }
}
