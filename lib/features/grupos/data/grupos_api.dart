import 'package:dio/dio.dart';

import '../../../core/network/authenticated_dio.dart';
import '../../../core/network/rest_error.dart';
import 'grupo_models.dart';

class GruposApi {
  GruposApi({Dio? dio}) : _dio = dio ?? createAuthenticatedDio();

  final Dio _dio;

  /// POST /api/grupos → 201
  Future<GrupoCriado> criar({
    required String nomeGrupo,
    String? descricaoOpcional,
    List<String> emailsConvidados = const <String>[],
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/grupos',
      data: <String, dynamic>{
        'nomeGrupo': nomeGrupo,
        if (descricaoOpcional != null && descricaoOpcional.isNotEmpty)
          'descricaoOpcional': descricaoOpcional,
        'emailsConvidados': emailsConvidados,
      },
      options: Options(
        validateStatus: (int? status) => status == 201,
      ),
    );

    final Map<String, dynamic> data = _asStringKeyMap(response.data);
    return GrupoCriado.fromJson(data);
  }

  /// GET /api/grupos/{idGrupo}
  Future<GrupoDetalhe> obterDetalhe(String idGrupo) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/api/grupos/$idGrupo',
    );
    final Map<String, dynamic> data = _asStringKeyMap(response.data);
    return GrupoDetalhe.fromJson(data);
  }

  String getErrorMessage(Object error) => restErrorMessage(error);

  Map<String, dynamic> _asStringKeyMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map(
        (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
      );
    }
    throw StateError('Resposta inesperada da API.');
  }
}
