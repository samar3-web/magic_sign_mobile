import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:magic_sign_mobile/controller/loginController.dart';
import 'package:magic_sign_mobile/model/Playlist.dart';

class WidgetController extends GetxController {

 LoginController loginController = Get.put(LoginController());

  String get apiUrl => loginController.baseUrl;


  deleteWidget(int playlistId, int displayOrder) async {
  

    try {
      final response = await http.get(Uri.parse('${loginController.baseUrl}/web/api/delete_widget.php?playlistId=$playlistId&displayOrder=$displayOrder'));
      if (response.statusCode == 200) {
        print('Widget deleted successfully.');
      } else {
        print('Failed to delete widget. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while deleting widget: $e');
    }
  }
}
