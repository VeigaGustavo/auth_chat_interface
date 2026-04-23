import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../../core/config/app_config.dart';
import 'chat_message.dart';

class ChatClient {
  StompClient? _stompClient;
  final StreamController<ChatMessage> _messagesController =
      StreamController<ChatMessage>.broadcast();

  Stream<ChatMessage> get messages => _messagesController.stream;

  /// SockJS em [AppConfig.sockJsWsUrl] com `tokenAcesso` na query (preferido).
  void connect({
    required String tokenAcesso,
    required void Function(String) onError,
  }) {
    _stompClient?.deactivate();

    final String encoded = Uri.encodeComponent(tokenAcesso);
    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: '${AppConfig.sockJsWsUrl}?tokenAcesso=$encoded',
        onConnect: (StompFrame frame) {
          _stompClient?.subscribe(
            destination: '/topic/mensagens-geral',
            callback: (StompFrame frame) {
              final String body = frame.body ?? '{}';
              final dynamic decoded = jsonDecode(body);
              if (decoded is Map<String, dynamic>) {
                _messagesController.add(ChatMessage.fromJson(decoded));
              }
            },
          );
        },
        onStompError: (StompFrame frame) {
          onError(frame.body ?? 'Erro STOMP.');
        },
        onWebSocketError: (dynamic error) {
          onError(error.toString());
        },
      ),
    );

    _stompClient?.activate();
  }

  void send(String conteudoMensagem) {
    if ((_stompClient?.connected ?? false) == false) {
      return;
    }
    _stompClient?.send(
      destination: '/app/conversa.enviar',
      body: jsonEncode(<String, dynamic>{
        'conteudoMensagem': conteudoMensagem,
      }),
    );
  }

  void dispose() {
    _stompClient?.deactivate();
    _messagesController.close();
  }
}
