import 'package:dio/dio.dart';

/// Extrai mensagem legível de erros REST (`mensagem`, `detalhesCampos`, …) e [DioException].
String restErrorMessage(
  Object error, {
  String credenciaisInvalidas = 'Credenciais de acesso inválidas.',
}) {
  if (error is DioException) {
    final dynamic data = error.response?.data;
    final String composed = mensagemCompostaFromResponseBody(data);
    if (composed.isNotEmpty) {
      return composed;
    }
    if (error.response?.statusCode == 401) {
      return credenciaisInvalidas;
    }
    return error.message ?? 'Erro de rede.';
  }
  return 'Erro inesperado.';
}

/// Junta [mensagem] + [detalhesCampos] quando a API os envia (ex.: validação 400).
String mensagemCompostaFromResponseBody(dynamic data) {
  final String? base = mensagemFromResponseBody(data);
  final String detalhes = detalhesCamposTexto(data);
  if (base != null && base.isNotEmpty) {
    if (detalhes.isEmpty) {
      return base;
    }
    return '$base\n\n$detalhes';
  }
  return detalhes;
}

String detalhesCamposTexto(dynamic data) {
  if (data is! Map) {
    return '';
  }
  final Map<String, dynamic> map = data.map(
    (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
  );
  final dynamic dc = map['detalhesCampos'];
  if (dc is! Map) {
    return '';
  }
  final List<String> linhas = <String>[];
  dc.forEach((dynamic k, dynamic v) {
    final String valor = _valorCampoParaTexto(v);
    linhas.add('${k.toString()}: $valor');
  });
  return linhas.join('\n');
}

String _valorCampoParaTexto(dynamic v) {
  if (v == null) {
    return '';
  }
  if (v is String) {
    return v;
  }
  if (v is List<dynamic>) {
    return v.map((dynamic e) => e.toString()).join('; ');
  }
  return v.toString();
}

String? mensagemFromResponseBody(dynamic data) {
  if (data is! Map) {
    return null;
  }
  final Map<String, dynamic> map = data.map(
    (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
  );
  final dynamic m = map['mensagem'];
  if (m is String && m.isNotEmpty) {
    return m;
  }
  final dynamic errors = map['errors'];
  if (errors is List<dynamic> && errors.isNotEmpty) {
    final dynamic first = errors.first;
    if (first is Map) {
      final Map<String, dynamic> err = first.map(
        (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
      );
      for (final String key in <String>[
        'defaultMessage',
        'message',
        'mensagem',
      ]) {
        final dynamic v = err[key];
        if (v is String && v.isNotEmpty) {
          return v;
        }
      }
    }
  }
  return null;
}
