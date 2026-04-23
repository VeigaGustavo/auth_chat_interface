import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../session/session_store.dart';

/// Cliente REST com `Authorization: Bearer` a partir da sessão atual.
Dio createAuthenticatedDio() {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.httpBaseUrl,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      validateStatus: (int? status) =>
          status != null && status >= 200 && status < 300,
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        final String? token = SessionStore.instance.tokenAcesso;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );
  return dio;
}
