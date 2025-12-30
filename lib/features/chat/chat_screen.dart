import 'package:flutter/material.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/services/api_client.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_theme.dart';
import '../../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = Message(
      id: 'welcome',
      userId: 'system',
      role: 'assistant',
      content: 'Hey! What\'s on your mind? 👻',
      createdAt: DateTime.now(),
    );
    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'user',
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Prepare chat history
      final history = _messages.map((msg) => {
        'role': msg.role,
        'content': msg.content,
      }).toList();

      final response = await ApiClient.post(
        ApiConfig.chat,
        data: {
          'message': text,
          'history': history,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final assistantMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'assistant',
          role: 'assistant',
          content: data['message'] ?? 'I\'m thinking...',
          xpAwarded: data['xpAwarded'],
          createdAt: DateTime.now(),
        );

        setState(() {
          _messages.add(assistantMessage);
        });

        _scrollToBottom();
      }
    } catch (e) {
      final errorMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'system',
        role: 'system',
        content: 'Sorry, something went wrong. Try again? 😅',
        createdAt: DateTime.now(),
      );

      setState(() {
        _messages.add(errorMessage);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.ghostAuraGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('👻', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ghost Chat',
                          style: TextStyle(
                            color: AppTheme.ghostWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Always here to help',
                          style: TextStyle(
                            color: AppTheme.ghostWhite.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      color: AppTheme.ghostWhite,
                      onPressed: () {
                        _showChatOptions();
                      },
                    ),
                  ],
                ),
              ),

              const Divider(
                color: Colors.white12,
                height: 1,
              ),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _MessageBubble(message: message);
                  },
                ),
              ),

              // Loading indicator
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.auraStart,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Ghost is thinking...',
                            style: TextStyle(
                              color: AppTheme.ghostWhite,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Input field
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: AppTheme.ghostWhite),
                          decoration: InputDecoration(
                            hintText: 'Message Ghost...',
                            hintStyle: TextStyle(
                              color: AppTheme.ghostWhite.withOpacity(0.4),
                            ),
                            border: InputBorder.none,
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.ghostAuraGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                        ),
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

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text(
                  'Clear Chat History',
                  style: TextStyle(color: AppTheme.ghostWhite),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _messages.clear();
                    _addWelcomeMessage();
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: AppTheme.ghostWhite),
                title: const Text(
                  'About Ghost AI',
                  style: TextStyle(color: AppTheme.ghostWhite),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Show about dialog
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.ghostAuraGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('👻', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.auraStart.withOpacity(0.8)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
              ),
              child: Text(
                message.content,
                style: const TextStyle(
                  color: AppTheme.ghostWhite,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}