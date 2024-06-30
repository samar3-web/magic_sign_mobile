import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  // Key to store the theme mode
  final String themeKey = 'isDarkMode';

  // Instance of GetStorage
  final GetStorage box = GetStorage();

  // Reactive variable to hold the theme mode state
  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load the theme mode state from storage
    isDarkMode.value = box.read(themeKey) ?? false;
  }

  // Method to toggle the theme mode
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    // Save the updated theme mode state to storage
    box.write(themeKey, isDarkMode.value);
  }
}
