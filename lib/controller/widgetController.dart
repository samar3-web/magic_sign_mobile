import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:magic_sign_mobile/model/Playlist.dart';

class WidgetController extends GetxController {
  deleteWidget(int playlistId, int displayOrder) async {
    final String url =
        'https://magic-sign.cloud/v_ar/web/api/delete_widget.php?playlistId=$playlistId&displayOrder=$displayOrder';
    print('Request URL: $url');

    try {
      final response = await http.get(Uri.parse(url));
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
