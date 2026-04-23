class SessaoAutenticacao {
  SessaoAutenticacao({
    required this.tokenAcesso,
    required this.esquemaAutorizacao,
    required this.expiraAproximadaEmSegundos,
    required this.nivelPapelAcesso,
    required this.permissoesAcessoEfetivas,
    this.nomeCompletoTitular,
  });

  final String tokenAcesso;
  final String esquemaAutorizacao;
  final int expiraAproximadaEmSegundos;
  final String nivelPapelAcesso;
  final List<String> permissoesAcessoEfetivas;
  final String? nomeCompletoTitular;

  factory SessaoAutenticacao.fromJson(Map<String, dynamic> json) {
    final dynamic perms = json['permissoesAcessoEfetivas'];
    return SessaoAutenticacao(
      tokenAcesso: json['tokenAcesso'] as String? ?? '',
      esquemaAutorizacao: json['esquemaAutorizacao'] as String? ?? 'Bearer',
      expiraAproximadaEmSegundos: (json['expiraAproximadaEmSegundos'] as num?)?.toInt() ?? 0,
      nivelPapelAcesso: json['nivelPapelAcesso'] as String? ?? '',
      permissoesAcessoEfetivas: perms is List<dynamic>
          ? perms.map((dynamic e) => e.toString()).toList()
          : const <String>[],
      nomeCompletoTitular: json['nomeCompletoTitular'] as String?,
    );
  }
}
