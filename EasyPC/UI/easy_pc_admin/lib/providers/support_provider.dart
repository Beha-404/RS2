import 'dart:async';
import 'package:desktop/models/support_message.dart';
import 'package:desktop/services/signalr_service.dart';
import 'package:flutter/material.dart';

class SupportProvider extends ChangeNotifier {
  final SignalRService _signalRService = SignalRService();
  Timer? _refreshTimer;

  List<Conversation> _conversations = [];
  List<SupportMessage> _messages = [];
  Conversation? _selectedConversation;
  bool _isConnected = false;
  bool _loading = false;
  String? _errorMessage;

  List<Conversation> get conversations => _conversations;
  List<SupportMessage> get messages => _messages;
  Conversation? get selectedConversation => _selectedConversation;
  bool get isConnected => _isConnected;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  Future<void> connect(String username, String password) async {
    try {
      _loading = true;
      _errorMessage = null;
      notifyListeners();

      // Set callbacks before connecting to avoid missing messages
      _signalRService.onMessageReceived = _handleNewMessage;
      _signalRService.onConnectionError = _handleConnectionError;
      _signalRService.onConnectionStateChanged = _handleConnectionStateChanged;

      await _signalRService.connect(username, password);

      await loadConversations();

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _errorMessage = 'Failed to connect: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadConversations() async {
    try {
      _conversations = await _signalRService.getAllConversations();
      notifyListeners();
    } catch (e) {
      print('Desktop: Error loading conversations: $e');
      _errorMessage = 'Failed to load conversations: $e';
      notifyListeners();
    }
  }

  Future<void> selectConversation(Conversation conversation) async {
    _selectedConversation = conversation;
    notifyListeners();

    await loadMessages();
    
    await _signalRService.markConversationAsRead(conversation.userId);
    
    await loadConversations();
  }

  Future<void> loadMessages() async {
    try {
      _loading = true;
      notifyListeners();

      final allMessages = await _signalRService.getMessageHistory();

      if (_selectedConversation != null) {
        _messages = allMessages
            .where((msg) => msg.conversationUserId == _selectedConversation!.userId)
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      } else {
        _messages = [];
      }

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _errorMessage = 'Failed to load messages: $e';
      notifyListeners();
    }
  }

  Future<void> sendMessage(String message) async {
    if (!_isConnected || _selectedConversation == null) return;

    try {
      await _signalRService.sendMessage(
        message,
        targetUserId: _selectedConversation!.userId,
      );
    } catch (e) {
      _errorMessage = 'Failed to send message: $e';
      notifyListeners();
    }
  }

  void _handleNewMessage(SupportMessage message) {
    print('Desktop: Received new message from ${message.senderName}: ${message.message}');

    if (_selectedConversation != null &&
        message.conversationUserId == _selectedConversation!.userId) {
      _messages.add(message);
      notifyListeners();
    }

    loadConversations();
  }

  void _handleConnectionError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _handleConnectionStateChanged(bool connected) {
    _isConnected = connected;
    notifyListeners();
  }

  void disconnect() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _signalRService.disconnect();
    _isConnected = false;
    _conversations = [];
    _messages = [];
    _selectedConversation = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _signalRService.dispose();
    super.dispose();
  }
}
