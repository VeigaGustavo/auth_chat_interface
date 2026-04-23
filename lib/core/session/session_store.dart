class SessionStore {
  SessionStore._();

  static final SessionStore instance = SessionStore._();

  String? tokenAcesso;
  String? esquemaAutorizacao;
  int? expiraAproximadaEmSegundos;
  String? nivelPapelAcesso;
  List<String> permissoesAcessoEfetivas = <String>[];
  String? nomeCompletoTitular;

  bool get isAuthenticated => (tokenAcesso ?? '').isNotEmpty;

  void clear() {
    tokenAcesso = null;
    esquemaAutorizacao = null;
    expiraAproximadaEmSegundos = null;
    nivelPapelAcesso = null;
    permissoesAcessoEfetivas = <String>[];
    nomeCompletoTitular = null;
  }
}
