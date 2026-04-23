class AppConfig {
  /// Base HTTP da API (REST).
  static const String httpBaseUrl = 'http://localhost:8080';

  /// SockJS usa URL **http(s)**, não `ws://`.
  static const String sockJsWsUrl = 'http://localhost:8080/ws';
}
