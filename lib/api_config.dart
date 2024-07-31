
class ApiConfig {
  static String? baseUrl;
  static String? clientId;
  static String? clientSecret;

  static void setConfiguration(String baseUrl, String clientId, String clientSecret) {
    ApiConfig.baseUrl = baseUrl;
    ApiConfig.clientId = clientId;
    ApiConfig.clientSecret = clientSecret;
  }
  
  static String getFullUrl(String endpoint) {
    return Uri.parse('${ApiConfig.baseUrl}$endpoint').toString();
  }
}
