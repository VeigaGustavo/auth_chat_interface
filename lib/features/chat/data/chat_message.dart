class ChatMessage {
  ChatMessage({
    this.idMensagem,
    required this.idContaRemetente,
    required this.nomeExibicaoRemetente,
    required this.conteudoMensagem,
    required this.instanteEnvio,
  });

  /// Identificador persistido (histórico REST); ausente nas mensagens só STOMP antigas.
  final String? idMensagem;
  final String idContaRemetente;
  final String nomeExibicaoRemetente;
  final String conteudoMensagem;
  final DateTime instanteEnvio;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final String? idRaw = json['idMensagem']?.toString() ?? json['id']?.toString();
    return ChatMessage(
      idMensagem: (idRaw != null && idRaw.isNotEmpty) ? idRaw : null,
      idContaRemetente: json['idContaRemetente']?.toString() ?? '',
      nomeExibicaoRemetente: json['nomeExibicaoRemetente'] as String? ?? '',
      conteudoMensagem: json['conteudoMensagem'] as String? ?? '',
      instanteEnvio: DateTime.tryParse(json['instanteEnvio'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
