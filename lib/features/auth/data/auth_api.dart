import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/rest_error.dart';
import 'sessao_autenticacao.dart';

class AuthApi {
  AuthApi()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.httpBaseUrl,
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            validateStatus: (int? status) =>
                status != null && status >= 200 && status < 300,
          ),
        );

  final Dio _dio;

  /// POST /api/autenticacao/entrar
  Future<SessaoAutenticacao> entrar({
    required String emailCorporativo,
    required String senhaAcesso,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/autenticacao/entrar',
      data: <String, dynamic>{
        'emailCorporativo': emailCorporativo,
        'senhaAcesso': senhaAcesso,
      },
    );

    final Map<String, dynamic> data = _asStringKeyMap(response.data);
    final SessaoAutenticacao sessao = SessaoAutenticacao.fromJson(data);
    if (sessao.tokenAcesso.isEmpty) {
      throw AuthApiException('Resposta inválida: falta tokenAcesso.');
    }
    return sessao;
  }

  /// POST /api/autenticacao/registrar → 201. Registo público: [nivelPapelAcesso] tipicamente `USUARIO_CONVIDADO`.
  Future<SessaoAutenticacao> registrar({
    required String emailCorporativo,
    required String senhaAcesso,
    required String nomeCompletoTitular,
    String? nivelPapelAcesso,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/autenticacao/registrar',
      data: <String, dynamic>{
        'emailCorporativo': emailCorporativo,
        'senhaAcesso': senhaAcesso,
        'nomeCompletoTitular': nomeCompletoTitular,
        if (nivelPapelAcesso != null && nivelPapelAcesso.isNotEmpty)
          'nivelPapelAcesso': nivelPapelAcesso,
      },
      options: Options(
        validateStatus: (int? status) => status == 201,
      ),
    );

    final Map<String, dynamic> data = _asStringKeyMap(response.data);
    final SessaoAutenticacao sessao = SessaoAutenticacao.fromJson(data);
    if (sessao.tokenAcesso.isEmpty) {
      throw AuthApiException('Resposta inválida: falta tokenAcesso.');
    }
    return sessao;
  }

  /// POST /api/autenticacao/solicitar-redefinicao-senha?emailCorporativo=...
  /// 202 Accepted, corpo vazio.
  Future<void> solicitarRedefinicaoSenha({
    required String emailCorporativo,
  }) async {
    await _dio.post<dynamic>(
      '/api/autenticacao/solicitar-redefinicao-senha',
      queryParameters: <String, dynamic>{
        'emailCorporativo': emailCorporativo,
      },
      options: Options(
        validateStatus: (int? status) => status == 202,
      ),
    );
  }

  /// POST /api/autenticacao/redefinir-senha — 204 No Content.
  Future<void> redefinirSenha({
    required String tokenRedefinicao,
    required String novaSenhaAcesso,
  }) async {
    await _dio.post<dynamic>(
      '/api/autenticacao/redefinir-senha',
      data: <String, dynamic>{
        'tokenRedefinicao': tokenRedefinicao,
        'novaSenhaAcesso': novaSenhaAcesso,
      },
      options: Options(
        validateStatus: (int? status) => status == 204,
      ),
    );
  }

  /// Verifica se o host responde (não faz parte do contrato oficial).
  Future<bool> healthcheck() async {
    try {
      await _dio.get<dynamic>(
        '/',
        options: Options(
          receiveTimeout: const Duration(seconds: 3),
          validateStatus: (int? status) =>
              status != null && status < 600,
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _asStringKeyMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map(
        (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
      );
    }
    throw AuthApiException('Resposta inesperada da API.');
  }

  String getErrorMessage(Object error) {
    if (error is AuthApiException) {
      return error.message;
    }
    return restErrorMessage(error);
  }
}

class AuthApiException implements Exception {
  AuthApiException(this.message);

  final String message;
}
