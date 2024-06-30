import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final String themeKey = 'isDarkMode';

  final GetStorage box = GetStorage();

  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = box.read(themeKey) ?? false;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    box.write(themeKey, isDarkMode.value);
  }
}
