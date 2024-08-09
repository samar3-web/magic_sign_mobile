class ApiConfig {
  static List<String>? baseUrl;
  static List<String>? clientId;
  static List<String>? clientSecret;
  static String? activeServerUrl;

  static void setConfiguration(List<String> baseUrl, List<String> clientId, List<String> clientSecret) {
    ApiConfig.baseUrl = baseUrl;
    ApiConfig.clientId = clientId;
    ApiConfig.clientSecret = clientSecret;
  }

  static List<String> getBaseUrls() {
    return baseUrl ?? [];
  }

  static List<String> getClientIds() {
    return clientId ?? [];
  }

  static List<String> getClientSecrets() {
    return clientSecret ?? [];
  }
}
