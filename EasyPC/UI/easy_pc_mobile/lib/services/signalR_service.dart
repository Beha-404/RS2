import 'dart:convert';
import 'package:easy_pc/config/config.dart';
import 'package:easy_pc/models/support_message.dart';
import 'package:signalr_netcore/signalr_client.dart';

class SignalRService {
  HubConnection? _hubConnection;
  late String _hubUrl;
  Function(SupportMessage)? onMessageReceived;
  Function(String)? onConnectionError;
  Function(bool)? onConnectionStateChanged;

  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;

  SignalRService() {
    _hubUrl = _getHubUrl();
  }

  String _getHubUrl() {
    final baseUrl = apiBaseUrl;
    return '$baseUrl/supportHub';
  }

  Future<void> connect(String username, String password) async {
    try {
      final credentials = base64Encode(utf8.encode('$username:$password'));

      final encodedCredentials = Uri.encodeComponent(credentials);

      final hubUrlWithAuth = '$_hubUrl?access_token=$encodedCredentials';

      print('SignalR: Attempting to connect to: $_hubUrl');

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            hubUrlWithAuth,
            options: HttpConnectionOptions(
              transport: HttpTransportType.LongPolling,
              skipNegotiation: false,
            ),
          )
          .withAutomaticReconnect()
          .build();

      _setupEventHandlers();

      print('SignalR: Starting connection...');
      await _hubConnection!.start();
      print('SignalR: Connected successfully to: $_hubUrl');
      onConnectionStateChanged?.call(true);
    } catch (e) {
      print('SignalR Connection Error: $e');
      print('SignalR Error Type: ${e.runtimeType}');
      onConnectionError?.call('Failed to connect: $e');
      onConnectionStateChanged?.call(false);
      rethrow;
    }
  }

  void _setupEventHandlers() {
    _hubConnection!.on('ReceiveMessage', _handleReceiveMessage);

    _hubConnection!.onreconnecting(({error}) {
      print('SignalR Reconnecting...');
      onConnectionStateChanged?.call(false);
    });

    _hubConnection!.onreconnected(({connectionId}) {
      print('SignalR Reconnected! Connection ID: $connectionId');
      onConnectionStateChanged?.call(true);
    });

    _hubConnection!.onclose(({error}) {
      print('SignalR Connection Closed: $error');
      onConnectionStateChanged?.call(false);
    });
  }

  void _handleReceiveMessage(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final messageData = arguments[0] as Map<String, dynamic>;
      final message = SupportMessage.fromJson(messageData);
      onMessageReceived?.call(message);
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  Future<void> sendMessage(String message, {int? targetUserId}) async {
    if (!isConnected) {
      throw Exception('Not connected to SignalR hub');
    }

    try {
      print('SignalR: Sending message: "$message" to targetUserId: $targetUserId');
      
      await _hubConnection!.invoke(
        'SendMessage',
        args: [message, targetUserId ?? 0],
      );
      
      print('SignalR: Message sent successfully');
    } catch (e) {
      print('Error sending message: $e');
      onConnectionError?.call('Failed to send message: $e');
      rethrow;
    }
  }

  Future<List<SupportMessage>> getMessageHistory() async {
    if (!isConnected) {
      throw Exception('Not connected to SignalR hub');
    }

    try {
      final result = await _hubConnection!.invoke('GetMessageHistory');

      if (result == null) return [];

      final List<dynamic> messageList = result as List<dynamic>;
      return messageList
          .map((json) => SupportMessage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting message history: $e');
      onConnectionError?.call('Failed to load messages: $e');
      return [];
    }
  }

  Future<void> disconnect() async {
    try {
      await _hubConnection?.stop();
      _hubConnection = null;
      onConnectionStateChanged?.call(false);
      print('SignalR Disconnected');
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  void dispose() {
    disconnect();
  }
}
