import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/session_store.dart';
import '../../../core/theme/app_monochrome.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/glass_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../grupos/data/grupo_models.dart';
import '../../grupos/data/grupos_api.dart';
import '../data/chat_client.dart';
import '../data/chat_message.dart';
import '../data/conversa_api.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatClient _chatClient = ChatClient();
  final ConversaApi _conversaApi = ConversaApi();
  final GruposApi _gruposApi = GruposApi();
  final List<ChatMessage> _messages = <ChatMessage>[];
  String? _connectionError;
  bool _historyLoading = true;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    final String? token = SessionStore.instance.tokenAcesso;
    if (token == null || token.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
      return;
    }

    unawaited(_loadHistory());

    _chatClient.connect(
      tokenAcesso: token,
      onError: (String error) {
        if (!mounted) {
          return;
        }
        setState(() => _connectionError = error);
      },
    );

    _chatClient.messages.listen((ChatMessage message) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (_messages.any((ChatMessage m) => _sameLogicalMessage(m, message))) {
          return;
        }
        _messages.add(message);
        _messages.sort(
          (ChatMessage a, ChatMessage b) => a.instanteEnvio.compareTo(b.instanteEnvio),
        );
      });
    });
  }

  Future<void> _loadHistory() async {
    setState(() {
      _historyLoading = true;
      _historyError = null;
    });
    try {
      final List<ChatMessage> historico =
          await _conversaApi.listarMensagensSalaGeral(limite: 50);
      if (!mounted) {
        return;
      }
      setState(() {
        for (final ChatMessage h in historico) {
          if (!_messages.any((ChatMessage m) => _sameLogicalMessage(m, h))) {
            _messages.add(h);
          }
        }
        _messages.sort(
          (ChatMessage a, ChatMessage b) => a.instanteEnvio.compareTo(b.instanteEnvio),
        );
        _historyLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      if (e is DioException && e.response?.statusCode == 401) {
        SessionStore.instance.clear();
        context.go('/login');
        return;
      }
      setState(() {
        _historyLoading = false;
        _historyError = _conversaApi.getErrorMessage(e);
      });
    }
  }

  /// Evita duplicar a mesma mensagem vinda do REST e do STOMP (com ou sem `idMensagem`).
  bool _sameLogicalMessage(ChatMessage a, ChatMessage b) {
    if (a.idMensagem != null &&
        b.idMensagem != null &&
        a.idMensagem!.isNotEmpty &&
        a.idMensagem == b.idMensagem) {
      return true;
    }
    if (a.idContaRemetente == b.idContaRemetente &&
        a.conteudoMensagem == b.conteudoMensagem &&
        a.instanteEnvio.difference(b.instanteEnvio).inSeconds.abs() <= 8) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppMonochrome.bg,
      body: GlassBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.28),
                        ),
                      ),
                      child: const AppLogo(size: 28),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Chat VeigaGustavo',
                            style: TextStyle(
                              color: AppMonochrome.ink,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_sessionSubtitle(SessionStore.instance) != null)
                            Text(
                              _sessionSubtitle(SessionStore.instance)!,
                              style: const TextStyle(
                                color: AppMonochrome.inkMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Grupos',
                      onPressed: _openGruposDialog,
                      icon: const Icon(
                        Icons.group_add_outlined,
                        color: AppMonochrome.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        SessionStore.instance.clear();
                        context.go('/login');
                      },
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: AppMonochrome.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_connectionError != null) ...[
                GlassCard(
                  child: Text(
                    'Falha na conexão: $_connectionError',
                    style: const TextStyle(
                      color: AppMonochrome.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (_historyLoading)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: LinearProgressIndicator(
                            minHeight: 3,
                            color: AppMonochrome.white,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      if (_historyError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Histórico: $_historyError',
                            style: TextStyle(
                              color: Colors.amber.shade200,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      Expanded(
                        child: _messages.isEmpty
                            ? Center(
                                child: Text(
                                  _historyLoading
                                      ? 'A carregar mensagens…'
                                      : 'Conectado. Envie a primeira mensagem.',
                                  style: const TextStyle(
                                    color: AppMonochrome.inkMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _messages.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final ChatMessage message = _messages[index];
                                  return Align(
                                    alignment: index.isEven
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.45),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.22),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            message.nomeExibicaoRemetente.isNotEmpty
                                                ? message.nomeExibicaoRemetente
                                                : message.idContaRemetente,
                                            style: const TextStyle(
                                              color: AppMonochrome.inkMuted,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            message.conteudoMensagem,
                                            style: const TextStyle(
                                              color: AppMonochrome.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(
                          color: AppMonochrome.white,
                          fontWeight: FontWeight.w500,
                        ),
                        cursorColor: AppMonochrome.white,
                        decoration: InputDecoration(
                          hintText: 'Digite sua mensagem',
                          hintStyle: TextStyle(
                            color: AppMonochrome.inkSubtle.withValues(alpha: 0.9),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(
                        Icons.send_rounded,
                        color: AppMonochrome.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    final String message = _messageController.text.trim();
    if (message.isEmpty) {
      return;
    }

    _chatClient.send(message);
    _messageController.clear();
  }

  String? _sessionSubtitle(SessionStore s) {
    final String nome = (s.nomeCompletoTitular ?? '').trim();
    if (nome.isNotEmpty) {
      return nome;
    }
    final String papel = (s.nivelPapelAcesso ?? '').trim();
    if (papel.isNotEmpty) {
      return papel;
    }
    return null;
  }

  Future<void> _openGruposDialog() async {
    final TextEditingController nomeGrupo = TextEditingController();
    final TextEditingController descricao = TextEditingController();
    final TextEditingController emails = TextEditingController();

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AppMonochrome.bgElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppMonochrome.line),
          ),
          title: const Text(
            'Novo grupo',
            style: TextStyle(
              color: AppMonochrome.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  controller: nomeGrupo,
                  style: const TextStyle(color: AppMonochrome.ink),
                  decoration: const InputDecoration(
                    labelText: 'Nome do grupo',
                    labelStyle: TextStyle(color: AppMonochrome.inkMuted),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descricao,
                  style: const TextStyle(color: AppMonochrome.ink),
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                    labelStyle: TextStyle(color: AppMonochrome.inkMuted),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emails,
                  style: const TextStyle(color: AppMonochrome.ink),
                  decoration: const InputDecoration(
                    labelText: 'E-mails convidados (vírgula ou linha)',
                    hintText: 'a@x.com, b@y.com',
                    labelStyle: TextStyle(color: AppMonochrome.inkMuted),
                    hintStyle: TextStyle(color: AppMonochrome.inkSubtle),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppMonochrome.inkMuted),
              ),
            ),
            FilledButton(
              onPressed: () async {
                final String nome = nomeGrupo.text.trim();
                if (nome.isEmpty) {
                  _showSnack('Indica o nome do grupo.');
                  return;
                }
                final List<String> listaEmails = emails.text
                    .split(RegExp(r'[\s,;]+'))
                    .map((String e) => e.trim())
                    .where((String e) => e.isNotEmpty)
                    .toList();
                try {
                  final GrupoCriado criado = await _gruposApi.criar(
                    nomeGrupo: nome,
                    descricaoOpcional:
                        descricao.text.trim().isEmpty ? null : descricao.text.trim(),
                    emailsConvidados: listaEmails,
                  );
                  if (!ctx.mounted) {
                    return;
                  }
                  Navigator.of(ctx).pop();
                  await _mostrarGrupoCriado(criado);
                } catch (e) {
                  _showSnack(_gruposApi.getErrorMessage(e));
                }
              },
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );

    nomeGrupo.dispose();
    descricao.dispose();
    emails.dispose();
  }

  Future<void> _mostrarGrupoCriado(GrupoCriado criado) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AppMonochrome.bgElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppMonochrome.line),
          ),
          title: const Text(
            'Grupo criado',
            style: TextStyle(
              color: AppMonochrome.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'ID: ${criado.idGrupo}\n'
            'Convites: ${criado.quantidadeEmailsConvidados}\n'
            'Criação: ${criado.instanteCriacao}',
            style: const TextStyle(color: AppMonochrome.inkMuted),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Fechar',
                style: TextStyle(color: AppMonochrome.inkMuted),
              ),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  final GrupoDetalhe detalhe =
                      await _gruposApi.obterDetalhe(criado.idGrupo);
                  if (!ctx.mounted) {
                    return;
                  }
                  Navigator.of(ctx).pop();
                  await _mostrarDetalheGrupo(detalhe);
                } catch (e) {
                  _showSnack(_gruposApi.getErrorMessage(e));
                }
              },
              child: const Text('Ver detalhe'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarDetalheGrupo(GrupoDetalhe g) async {
    final String emails = g.emailsConvidadosParaAcessoFuturo.join(', ');
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AppMonochrome.bgElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppMonochrome.line),
          ),
          title: Text(
            g.nomeGrupo,
            style: const TextStyle(
              color: AppMonochrome.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              '${g.descricaoOpcional ?? '—'}\n\n'
              'Conta criadora: ${g.idContaCriadora}\n'
              'Criação: ${g.instanteCriacao}\n\n'
              'Convidados: ${emails.isEmpty ? '—' : emails}',
              style: const TextStyle(color: AppMonochrome.inkMuted),
            ),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppMonochrome.line),
        ),
        backgroundColor: AppMonochrome.bgElevated,
        content: Text(
          message,
          style: const TextStyle(
            color: AppMonochrome.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
