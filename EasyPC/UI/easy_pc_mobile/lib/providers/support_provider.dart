import 'package:easy_pc/models/support_message.dart';
import 'package:easy_pc/services/signalR_service.dart';
import 'package:flutter/material.dart';

class SupportProvider extends ChangeNotifier {
  final SignalRService _signalRService = SignalRService();

  List<SupportMessage> _messages = [];
  bool _isConnected = false;
  bool _loading = false;
  String? _errorMessage;

  List<SupportMessage> get messages => _messages;
  bool get isConnected => _isConnected;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  Future<void> connect(String username, String password) async {
    try {
      print('SupportProvider: Starting connection for user: $username');
      _loading = true;
      _errorMessage = null;
      notifyListeners();

      _signalRService.onMessageReceived = _handleNewMessage;
      _signalRService.onConnectionError = _handleConnectionError;
      _signalRService.onConnectionStateChanged = _handleConnectionStateChanged;

      print('SupportProvider: Calling signalR connect...');
      await _signalRService.connect(username, password);

      print('SupportProvider: Connected! Loading messages...');
      await loadMessages();

      _loading = false;
      print('SupportProvider: Connection complete!');
      notifyListeners();
    } catch (e) {
      print('SupportProvider: Connection failed: $e');
      _loading = false;
      _errorMessage = 'Failed to connect: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadMessages() async {
    try {
      _loading = true;
      notifyListeners();

      _messages = await _signalRService.getMessageHistory();
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _errorMessage = 'Failed to load messages: $e';
      notifyListeners();
    }
  }

  Future<void> sendMessage(String message) async {
    if (!_isConnected) {
      print('SupportProvider: Cannot send - not connected!');
      return;
    }

    print('SupportProvider: Sending message: $message');
    try {
      await _signalRService.sendMessage(message);
      print('SupportProvider: Message sent successfully!');
    } catch (e) {
      print('SupportProvider: Failed to send message: $e');
      _errorMessage = 'Failed to send message: $e';
      notifyListeners();
      rethrow;
    }
  }

  void _handleNewMessage(SupportMessage message) {
    _messages.add(message);
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    notifyListeners();
  }

  void _handleConnectionError(String error) {
    _errorMessage = error;
    _isConnected = false;
    notifyListeners();
  }

  void _handleConnectionStateChanged(bool connected) {
    _isConnected = connected;
    if (connected) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void disconnect() {
    _signalRService.disconnect();
    _isConnected = false;
    _messages = [];
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
