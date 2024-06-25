import 'package:connectivity_plus/connectivity_plus.dart';

class Connectioncontroller {
  static isConnected() {
    return _isConnected();
  }

  static _isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    }
    return false;
  }
}
