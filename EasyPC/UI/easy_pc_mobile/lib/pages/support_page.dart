import 'package:easy_pc/models/support_message.dart';
import 'package:easy_pc/providers/support_provider.dart';
import 'package:easy_pc/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const yellow = Color(0xFFDDC03D);

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
      if (userProvider.user != null) {
        if (userProvider.password == null) {
          await userProvider.loadPassword();
        }

        await supportProvider.connect(
          userProvider.user!.username!,
          userProvider.password ?? '',
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
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: _buildAppBar(),
      body: Consumer<SupportProvider>(
        builder: (context, supportProvider, child) {
          return _buildBody(supportProvider);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF262626),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: yellow),
        onPressed: () => Navigator.pop(context),
      ),
      title: Consumer<SupportProvider>(
        builder: (context, supportProvider, child) {
          return Row(
            children: [
              const Text(
                'Support',
                style: TextStyle(color: yellow, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: supportProvider.isConnected ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: yellow),
          onPressed: _showSupportInfo,
        ),
      ],
    );
  }

  Widget _buildBody(SupportProvider supportProvider) {
    if (supportProvider.loading) {
      return const Center(
        child: CircularProgressIndicator(color: yellow),
      );
    }

    if (supportProvider.errorMessage != null && !supportProvider.isConnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Connection Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              supportProvider.errorMessage!,
              style: const TextStyle(color: Colors.white70),
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

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Support Page',
                style: TextStyle(
                  color: yellow,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Chat with our support team',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: supportProvider.messages.isEmpty
              ? _buildEmptyState()
              : _buildMessagesList(supportProvider.messages),
        ),

        _buildMessageInput(supportProvider),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent, size: 80, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start a conversation with our support team',
            style: TextStyle(color: Colors.white38, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<SupportMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) => _buildMessageBubble(messages[index]),
    );
  }

  Widget _buildMessageBubble(SupportMessage message) {
    final isAdmin = message.isAdmin;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isAdmin ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAdmin) ...[
            _buildAvatar(isAdmin),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? const Color(0xFF2A2A2A)
                        : yellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isAdmin ? 0 : 12),
                      bottomRight: Radius.circular(isAdmin ? 12 : 0),
                    ),
                    border: Border.all(
                      color: isAdmin
                          ? Colors.white12
                          : yellow.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.senderName,
                        style: TextStyle(
                          color: isAdmin ? yellow : yellow,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(message.timestamp),
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (!isAdmin) ...[
            const SizedBox(width: 8),
            _buildAvatar(isAdmin),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isAdmin) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isAdmin ? yellow.withValues(alpha: 0.2) : const Color(0xFF2A2A2A),
        shape: BoxShape.circle,
        border: Border.all(
          color: isAdmin ? yellow : Colors.white24,
        ),
      ),
      child: Icon(
        isAdmin ? Icons.support_agent : Icons.person,
        color: isAdmin ? yellow : Colors.white70,
        size: 20,
      ),
    );
  }

  Widget _buildMessageInput(SupportProvider supportProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: supportProvider.isConnected,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: supportProvider.isConnected
                      ? 'Type a message...'
                      : 'Connecting...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1F1F1F),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: yellow, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: supportProvider.isConnected ? _sendMessage : null,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: supportProvider.isConnected
                      ? yellow.withValues(alpha: 0.3)
                      : Colors.white12,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send,
                  color: supportProvider.isConnected ? yellow : Colors.white38,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
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

  void _showSupportInfo() {
    final supportProvider = context.read<SupportProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Support Information',
          style: TextStyle(color: yellow, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Our support team is available 24/7 to help you with any questions or concerns.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: supportProvider.isConnected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  supportProvider.isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    color: supportProvider.isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: yellow, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
