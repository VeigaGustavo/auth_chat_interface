import 'package:dio/dio.dart';

import '../../../core/network/authenticated_dio.dart';
import '../../../core/network/rest_error.dart';
import 'chat_message.dart';

class ConversaApi {
  ConversaApi({Dio? dio}) : _dio = dio ?? createAuthenticatedDio();

  final Dio _dio;

  /// GET /api/conversa/sala-geral/mensagens?limite=… — requer Bearer (mesmo formato do broadcast).
  Future<List<ChatMessage>> listarMensagensSalaGeral({int limite = 50}) async {
    final int n = limite.clamp(1, 200);
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/api/conversa/sala-geral/mensagens',
      queryParameters: <String, dynamic>{'limite': n},
    );

    final dynamic data = response.data;
    final List<dynamic> list = _extractList(data);

    return list.map((dynamic item) {
      if (item is! Map) {
        throw StateError('Item de mensagem inválido no histórico.');
      }
      final Map<String, dynamic> map = item.map(
        (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
      );
      return ChatMessage.fromJson(map);
    }).toList();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List<dynamic>) {
      return data;
    }
    if (data is Map) {
      final Map<String, dynamic> map = data.map(
        (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
      );
      for (final String key in <String>['mensagens', 'content', 'data', 'items']) {
        final dynamic inner = map[key];
        if (inner is List<dynamic>) {
          return inner;
        }
      }
    }
    throw StateError('Formato de histórico inesperado (esperada uma lista JSON).');
  }

  String getErrorMessage(Object error) => restErrorMessage(error);
}
