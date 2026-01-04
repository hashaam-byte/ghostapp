// lib/features/chat/gx_talk_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/services/api_client.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_theme.dart';
import '../../models/message_model.dart';

class GXTalkScreen extends StatefulWidget {
  const GXTalkScreen({super.key});

  @override
  State<GXTalkScreen> createState() => _GXTalkScreenState();
}

class _GXTalkScreenState extends State<GXTalkScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;

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
      content: 'Hey! What\'s going on? ⚡',
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
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
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
        
        // Simulate typing delay
        await Future.delayed(const Duration(milliseconds: 500));
        
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
          _isTyping = false;
        });

        _scrollToBottom();
      }
    } catch (e) {
      final errorMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'system',
        role: 'system',
        content: 'Something went wrong. Try again? 😅',
        createdAt: DateTime.now(),
      );

      setState(() {
        _messages.add(errorMessage);
        _isTyping = false;
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      color: AppTheme.ghostWhite,
                      onPressed: () => Navigator.pop(context),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.ghostAuraGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('⚡', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'GX Talk',
                            style: TextStyle(
                              color: AppTheme.ghostWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _isTyping ? 'typing...' : 'online',
                            style: TextStyle(
                              color: _isTyping 
                                  ? AppColors.auraStart 
                                  : AppColors.success,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      color: AppTheme.ghostWhite,
                      onPressed: _showOptions,
                    ),
                  ],
                ),
              ),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _MessageBubble(message: message)
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.1, end: 0);
                  },
                ),
              ),

              // Typing indicator
              if (_isTyping)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                          bottomLeft: Radius.circular(4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _TypingDot(delay: 0),
                          const SizedBox(width: 4),
                          _TypingDot(delay: 200),
                          const SizedBox(width: 4),
                          _TypingDot(delay: 400),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // Input field
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Voice button
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.mic),
                        color: AppTheme.ghostWhite.withOpacity(0.6),
                        onPressed: () {
                          // TODO: Voice input
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Voice coming soon!'),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(width: 12),

                    // Text field
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
                            hintText: 'Type something...',
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
                    
                    const SizedBox(width: 12),

                    // Send button
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.ghostAuraGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.auraStart.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
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

  void _showOptions() {
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
                  'Clear Chat',
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
                leading: const Icon(Icons.share, color: AppTheme.ghostWhite),
                title: const Text(
                  'Export Chat',
                  style: TextStyle(color: AppTheme.ghostWhite),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Export functionality
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
                child: Text('⚡', style: TextStyle(fontSize: 16)),
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
                gradient: isUser
                    ? AppColors.ghostAuraGradient
                    : null,
                color: isUser
                    ? null
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                          color: AppColors.auraStart.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
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

class _TypingDot extends StatelessWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.auraStart,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(duration: 600.ms, delay: delay.ms)
        .fadeOut(duration: 600.ms, delay: (delay + 300).ms);
  }
}