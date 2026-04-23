class GrupoCriado {
  GrupoCriado({
    required this.idGrupo,
    required this.nomeGrupo,
    required this.quantidadeEmailsConvidados,
    required this.instanteCriacao,
  });

  final String idGrupo;
  final String nomeGrupo;
  final int quantidadeEmailsConvidados;
  final String instanteCriacao;

  factory GrupoCriado.fromJson(Map<String, dynamic> json) {
    return GrupoCriado(
      idGrupo: json['idGrupo']?.toString() ?? '',
      nomeGrupo: json['nomeGrupo'] as String? ?? '',
      quantidadeEmailsConvidados:
          (json['quantidadeEmailsConvidados'] as num?)?.toInt() ?? 0,
      instanteCriacao: json['instanteCriacao'] as String? ?? '',
    );
  }
}

class GrupoDetalhe {
  GrupoDetalhe({
    required this.idGrupo,
    required this.nomeGrupo,
    required this.descricaoOpcional,
    required this.idContaCriadora,
    required this.instanteCriacao,
    required this.emailsConvidadosParaAcessoFuturo,
  });

  final String idGrupo;
  final String nomeGrupo;
  final String? descricaoOpcional;
  final String idContaCriadora;
  final String instanteCriacao;
  final List<String> emailsConvidadosParaAcessoFuturo;

  factory GrupoDetalhe.fromJson(Map<String, dynamic> json) {
    final dynamic emails = json['emailsConvidadosParaAcessoFuturo'];
    return GrupoDetalhe(
      idGrupo: json['idGrupo']?.toString() ?? '',
      nomeGrupo: json['nomeGrupo'] as String? ?? '',
      descricaoOpcional: json['descricaoOpcional'] as String?,
      idContaCriadora: json['idContaCriadora']?.toString() ?? '',
      instanteCriacao: json['instanteCriacao'] as String? ?? '',
      emailsConvidadosParaAcessoFuturo: emails is List<dynamic>
          ? emails.map((dynamic e) => e.toString()).toList()
          : const <String>[],
    );
  }
}
