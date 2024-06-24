class Zone {
  int zoneId;
  final double width;
  final double height;
  final double top;
  final double left;

  double get bottom => top + height;
  double get right => left + width;

  Zone({
    required this.zoneId,
    required this.width,
    required this.height,
    required this.top,
    required this.left,
  });

  factory Zone.fromJson(Map<String, dynamic> json,int zoneId) {
    try {
      return Zone(
        zoneId: zoneId,
        width: double.tryParse(json['width'].toString()) ?? 0.0,
        height: double.tryParse(json['height'].toString()) ?? 0.0,
        top: double.tryParse(json['top'].toString()) ?? 0.0,
        left: double.tryParse(json['left'].toString()) ?? 0.0,
      );
    } catch (e) {
      // Handle parsing error if necessary, maybe log to your error reporting service
      print("Error parsing Zone data: $e");
      return Zone(width: 0.0, height: 0.0, top: 0.0, left: 0.0, zoneId: 0);
    }
  }
}
