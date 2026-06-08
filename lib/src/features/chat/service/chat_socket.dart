import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../../core/config/app_config.dart';
import '../../../core/storage/token_storage.dart';
import '../models/chat_message.dart';

enum ChatConnState { connecting, connected, reconnecting, disconnected }

// Manages the STOMP-over-SockJS connection for a single match's chat.
// Reconnection is handled manually so a fresh JWT is read on every attempt.
class ChatSocket {
  final TokenStorage _tokenStorage;

  StompClient? _client;
  String? _matchId;
  void Function(ChatMessage)? _onMessage;
  void Function(ChatConnState)? _onState;
  bool _closed = false;
  bool _reconnectScheduled = false;
  bool _connected = false;
  Completer<void>? _connectCompleter;
  // Bumped on every (re)activation; stale clients' callbacks are ignored.
  int _generation = 0;

  ChatSocket(this._tokenStorage);

  bool get isConnected => _connected;

  String get _wsUrl => '${AppConfig.baseUrl}/api/v1/ws';

  Map<String, String> _authHeaders(String? token) => {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      };

  Future<void> connect({
    required String matchId,
    required void Function(ChatMessage) onMessage,
    required void Function(ChatConnState) onState,
  }) async {
    _matchId = matchId;
    _onMessage = onMessage;
    _onState = onState;
    _closed = false;
    await _activate(waitForConnect: true);
  }

  Future<void> _activate({required bool waitForConnect}) async {
    final gen = ++_generation; // this attempt owns this generation
    _reconnectScheduled = false;
    _connected = false;
    _onState?.call(
      _connectCompleter == null || (_connectCompleter?.isCompleted ?? true)
          ? ChatConnState.connecting
          : ChatConnState.reconnecting,
    );

    if (waitForConnect) {
      _connectCompleter = Completer<void>();
    }

    final token = await _tokenStorage.getToken();
    final headers = _authHeaders(token);
    debugPrint('[Chat] activating STOMP (gen $gen) → url=$_wsUrl '
        'token=${token == null ? "NULL" : "present(${token.length})"} '
        'match=$_matchId');

    // Detach the previous client first so its close callbacks (old gen) are
    // ignored and can't schedule a reconnect that kills this one.
    _client?.deactivate();

    bool stale() => gen != _generation || _closed;

    _client = StompClient(
      config: StompConfig.sockJS(
        url: _wsUrl,
        reconnectDelay: Duration.zero,
        connectionTimeout: const Duration(seconds: 12),
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
        onConnect: (frame) {
          if (stale()) {
            debugPrint('[Chat] (gen $gen) onConnect ignored — stale');
            return;
          }
          _onConnect(frame);
        },
        onWebSocketError: (error) {
          debugPrint('[Chat] ✖ onWebSocketError (gen $gen): $error');
          if (stale()) return;
          _failConnect(error);
          _scheduleReconnect();
        },
        onWebSocketDone: () {
          debugPrint('[Chat] ✖ onWebSocketDone (gen $gen). closed=$_closed');
          if (stale()) return;
          _connected = false;
          _scheduleReconnect();
        },
        onStompError: (frame) {
          debugPrint('[Chat] ✖ onStompError (gen $gen): cmd=${frame.command} '
              'headers=${frame.headers} body=${frame.body}');
          if (stale()) return;
          _failConnect(frame.body);
          _scheduleReconnect();
        },
        onDisconnect: (frame) {
          if (stale()) return;
          _connected = false;
        },
        // Raw STOMP frame log — shows CONNECT/CONNECTED/ERROR/heartbeats.
        onDebugMessage: (m) => debugPrint('[STOMP] $m'),
      ),
    );
    _client!.activate();

    if (waitForConnect && _connectCompleter != null) {
      await _connectCompleter!.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception(
          'Chat connection timed out. Check your network and try again.',
        ),
      );
    }
  }

  void _onConnect(StompFrame _) {
    _connected = true;
    _connectCompleter?.complete();
    _connectCompleter = null;
    _onState?.call(ChatConnState.connected);

    final topic = '/topic/match/$_matchId/chat';
    debugPrint('[Chat] STOMP connected → subscribing $topic');
    _client!.subscribe(
      destination: topic,
      callback: (frame) {
        final body = frame.body;
        debugPrint('[Chat] ◀ incoming frame: $body');
        if (body == null || body.isEmpty) return;
        try {
          final decoded = jsonDecode(body);
          final json = _unwrapMessageJson(decoded);
          if (json != null) {
            _onMessage?.call(ChatMessage.fromJson(json));
          } else {
            debugPrint('[Chat] ⚠ could not unwrap message frame');
          }
        } catch (e) {
          debugPrint('[Chat] ⚠ failed to parse frame: $e');
        }
      },
    );
  }

  void _failConnect(Object? detail) {
    _connected = false;
    if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
      final msg = detail?.toString().trim();
      _connectCompleter!.completeError(
        Exception(
          msg != null && msg.isNotEmpty
              ? 'Chat connection failed: $msg'
              : 'Chat connection failed.',
        ),
      );
    }
    _connectCompleter = null;
  }

  Map<String, dynamic>? _unwrapMessageJson(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      for (final key in ['payload', 'message', 'data', 'content']) {
        final nested = decoded[key];
        if (nested is Map<String, dynamic> &&
            (nested.containsKey('content') ||
                nested.containsKey('id') ||
                nested.containsKey('messageId'))) {
          return nested;
        }
      }
      return decoded;
    }
    return null;
  }

  void _scheduleReconnect() {
    if (_closed || _reconnectScheduled) return;
    _reconnectScheduled = true;
    _connected = false;
    debugPrint('[Chat] ⟳ scheduling reconnect in 3s');
    _onState?.call(ChatConnState.reconnecting);
    Future.delayed(const Duration(seconds: 3), () {
      if (!_closed) {
        debugPrint('[Chat] ⟳ reconnecting now');
        _activate(waitForConnect: false);
      }
    });
  }

  void send(String content) {
    final id = _matchId;
    if (id == null || !_connected || _client == null) {
      throw Exception('Not connected to chat yet.');
    }
    // Backend handler is @MessageMapping("/chat/{matchId}/send") → /app/chat/{id}/send
    final dest = '/app/chat/$id/send';
    final body = jsonEncode({'content': content});
    debugPrint('[Chat] ▶ sending to $dest: $body');
    _client!.send(
      destination: dest,
      headers: const {'content-type': 'application/json'},
      body: body,
    );
  }

  Future<void> disconnect() async {
    _closed = true;
    _connected = false;
    _generation++; // invalidate any in-flight callbacks
    _connectCompleter?.completeError(Exception('Chat closed'));
    _connectCompleter = null;
    // Give any just-published SEND frame a moment to flush before we tear the
    // socket down (otherwise sending then immediately leaving drops it).
    final client = _client;
    _client = null;
    _onState?.call(ChatConnState.disconnected);
    if (client != null) {
      await Future.delayed(const Duration(milliseconds: 250));
      client.deactivate();
    }
  }
}
