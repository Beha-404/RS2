import 'package:desktop/models/support_message.dart';
import 'package:desktop/providers/support_provider.dart';
import 'package:desktop/providers/user_provider.dart';
import 'package:desktop/widgets/desktop_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectToSignalR();
    });
  }

  Future<void> _connectToSignalR() async {
    final supportProvider = context.read<SupportProvider>();
    final userProvider = context.read<UserProvider>();

    try {
      if (userProvider.username != null && userProvider.password != null) {
        await supportProvider.connect(
          userProvider.username!,
          userProvider.password!,
        );
      } else {
        throw Exception('User not logged in');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect to support: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      await context.read<SupportProvider>().sendMessage(messageText);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFFFCC00);
    return Scaffold(
      appBar: const DesktopAppBar(currentPage: 'Support'),
      backgroundColor: const Color(0xFF23191A),
      body: _buildBody(yellow),
    );
  }

  Widget _buildBody(Color yellow) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF232325), Color(0xFF2B1C1C)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 32),
            child: Consumer<SupportProvider>(
              builder: (context, supportProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Support Center',
                          style: TextStyle(
                            color: yellow,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: supportProvider.isConnected
                                ? Colors.green
                                : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage user support conversations',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: supportProvider.loading
                          ? Center(
                              child:
                                  CircularProgressIndicator(color: yellow))
                          : supportProvider.errorMessage != null &&
                                  !supportProvider.isConnected
                              ? _buildErrorView(
                                  yellow, supportProvider.errorMessage!)
                              : _buildMainContent(yellow, supportProvider),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(Color yellow, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Connection Error',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _connectToSignalR,
            style: ElevatedButton.styleFrom(
              backgroundColor: yellow,
              foregroundColor: Colors.black,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(Color yellow, SupportProvider supportProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildConversationsList(yellow, supportProvider),
        _buildChatArea(yellow, supportProvider),
      ],
    );
  }

  Widget _buildConversationsList(
      Color yellow, SupportProvider supportProvider) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: yellow.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: yellow.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.forum, color: yellow, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Conversations (${supportProvider.conversations.length})',
                  style: TextStyle(
                    color: yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: supportProvider.conversations.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, color: Colors.white24, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'No conversations yet',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.zero,
                    children: supportProvider.conversations
                        .map((conversation) => _buildConversationTile(
                            yellow, conversation, supportProvider))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(Color yellow, Conversation conversation,
      SupportProvider supportProvider) {
    final isSelected =
        supportProvider.selectedConversation?.userId == conversation.userId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? yellow.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? yellow.withOpacity(0.5) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            supportProvider.selectConversation(conversation);
            _scrollToBottom();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: yellow.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: yellow.withOpacity(0.3), width: 2),
                  ),
                  child: Icon(Icons.person, color: yellow, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.username,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        conversation.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (conversation.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: yellow,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: yellow.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${conversation.unreadCount}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea(Color yellow, SupportProvider supportProvider) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: yellow.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (supportProvider.selectedConversation != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: yellow.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: yellow.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: yellow.withOpacity(0.3), width: 2),
                      ),
                      child: Icon(Icons.person, color: yellow, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      supportProvider.selectedConversation!.username,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: supportProvider.selectedConversation == null
                  ? _buildEmptyState(yellow)
                  : _buildMessagesList(yellow, supportProvider),
            ),
            if (supportProvider.selectedConversation != null)
              _buildMessageInput(yellow, supportProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color yellow) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: yellow.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline, size: 40, color: yellow.withOpacity(0.3)),
          ),
          const SizedBox(height: 24),
          Text(
            'Select a conversation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a user from the left to start chatting',
            style: TextStyle(color: Colors.white38, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(Color yellow, SupportProvider supportProvider) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return supportProvider.messages.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat, color: Colors.white24, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'No messages yet\nStart the conversation!',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: supportProvider.messages.length,
            itemBuilder: (context, index) {
              final message = supportProvider.messages[index];
              return _buildChatBubble(message);
            },
          );
  }

  Widget _buildChatBubble(SupportMessage message) {
    final yellow = const Color(0xFFFFCC00);
    final isAdmin = message.isAdmin;
    
    return Align(
      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: isAdmin ? const Color(0xFF2A2A2A) : yellow.withOpacity(0.15),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: isAdmin ? Radius.circular(4) : Radius.circular(16),
            bottomRight: isAdmin ? Radius.circular(16) : Radius.circular(4),
          ),
          border: Border.all(
            color: isAdmin ? Colors.white10 : yellow.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAdmin ? Icons.admin_panel_settings : Icons.person,
                  size: 14,
                  color: isAdmin ? Colors.green : yellow,
                ),
                const SizedBox(width: 6),
                Text(
                  message.senderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isAdmin ? Colors.green : yellow,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(Color yellow, SupportProvider supportProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(color: Colors.white10, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: yellow.withOpacity(0.2), width: 1),
              ),
              child: TextField(
                controller: _messageController,
                enabled: supportProvider.isConnected,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: supportProvider.isConnected
                      ? 'Type your message...'
                      : 'Connecting...',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: supportProvider.isConnected
                    ? [yellow, yellow.withOpacity(0.8)]
                    : [Colors.grey, Colors.grey.shade700],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: supportProvider.isConnected
                  ? [
                      BoxShadow(
                        color: yellow.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: supportProvider.isConnected ? _sendMessage : null,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Icon(
                    Icons.send,
                    color: supportProvider.isConnected ? Colors.black : Colors.white54,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
