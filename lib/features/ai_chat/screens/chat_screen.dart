import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/models/chat_message_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load chat history on init
    Future.microtask(() {
      ref.read(chatMessagesProvider.notifier).loadHistory();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    ref.read(chatMessagesProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider);
    final isLoadingReply = ref.watch(chatLoadingProvider);

    // Auto-scroll when messages change
    ref.listen<AsyncValue<List<ChatMessageModel>>>(chatMessagesProvider,
        (previous, next) {
      final prevCount = previous?.valueOrNull?.length ?? 0;
      final nextCount = next.valueOrNull?.length ?? 0;
      if (nextCount > prevCount) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(context),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. الخلفية مع التوهج
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.background,
              gradient: RadialGradient(
                colors: [Color(0x66FADADD), Colors.transparent],
                center: Alignment(-1, -1),
                radius: 1.0,
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x66D2E9CA), Colors.transparent],
                  center: Alignment(1, 1),
                  radius: 1.0,
                ),
              ),
            ),
          ),

          // 2. المحتوى (قائمة الرسائل وشريط الإدخال)
          Column(
            children: [
              // قائمة الرسائل
              Expanded(
                child: messagesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.pinkGlow,
                    ),
                  ),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(
                          'حدث خطأ أثناء تحميل المحادثة',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(chatMessagesProvider.notifier)
                                .loadHistory();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0x334F644B),
                            elevation: 0,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            'إعادة المحاولة',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  data: (messages) {
                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.black.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text(
                              'ابدأ محادثتك مع مساعد البشرة الذكي',
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.5),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(
                          16, 100, 16, 180),
                      itemCount: messages.length +
                          (isLoadingReply ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show typing indicator at the end
                        if (index == messages.length &&
                            isLoadingReply) {
                          return const _TypingIndicator();
                        }
                        final message = messages[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: message.isUser
                              ? _UserMessage(text: message.message)
                              : _AiMessage(text: message.message),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // 3. شريط الإدخال (مرفوع فوق شريط التنقل السفلي)
          Positioned(
            bottom: 90,
            left: 0,
            right: 0,
            child: _buildInputBar(context),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildGlassAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            backgroundColor: Colors.white.withValues(alpha: 0.7),
            elevation: 0,
            leadingWidth: 0,
            title: Row(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFFEAE7E7),
                      child: Icon(Icons.smart_toy,
                          size: 24, color: Color(0xFF4F644B)),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD2E9CA),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("مساعد البشرة الذكي",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    Text("متصل الآن",
                        style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, color: Colors.black),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                onSelected: (value) {
                  switch (value) {
                    case 'clear':
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('مسح المحادثة'),
                          content: const Text('هل تريد مسح جميع الرسائل؟'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ref.read(chatMessagesProvider.notifier).clearHistory();
                              },
                              child: const Text('مسح', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      break;
                    case 'refresh':
                      ref.read(chatMessagesProvider.notifier).loadHistory();
                      break;
                    case 'tips':
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('💡 نصيحة: استخدم صورة واضحة بإضاءة جيدة لأفضل تحليل')),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'clear', child: Row(children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 12),
                    Text('مسح المحادثة'),
                  ])),
                  const PopupMenuItem(value: 'refresh', child: Row(children: [
                    Icon(Icons.refresh, color: Colors.black54),
                    SizedBox(width: 12),
                    Text('تحديث'),
                  ])),
                  const PopupMenuItem(value: 'tips', child: Row(children: [
                    Icon(Icons.lightbulb_outline, color: Colors.amber),
                    SizedBox(width: 12),
                    Text('نصائح الاستخدام'),
                  ])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.background.withValues(alpha: 0.0),
            AppTheme.background
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('رفع صورة')),
                    );
                  },
                  icon: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Colors.black54),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration.collapsed(
                      hintText: "اسألي مساعدك الذكي...",
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black45),
                    ),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('الإدخال الصوتي')),
                    );
                  },
                  icon: const Icon(Icons.mic_none,
                      color: Colors.black54),
                ),
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        colors: [AppTheme.pinkGlow, AppTheme.greenGlow]),
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send,
                        color: Colors.black, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget مخصص لرسائل الـ AI
class _AiMessage extends StatelessWidget {
  final String text;
  const _AiMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFFEAE7E7),
          child:
              Icon(Icons.smart_toy, size: 18, color: Color(0xFF4F644B)),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
              topRight: Radius.circular(4),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0x99CFE6C7),
                child: Text(text,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget مخصص لرسائل المستخدم
class _UserMessage extends StatelessWidget {
  final String text;
  const _UserMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0x99FADADD),
                child: Text(text,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFFEAE7E7),
          child: Icon(Icons.person, size: 20, color: Colors.black54),
        ),
      ],
    );
  }
}

// Widget لمؤشر الكتابة
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animation1 = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );
    _animation2 = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeInOut),
      ),
    );
    _animation3 = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFFEAE7E7),
          child:
              Icon(Icons.smart_toy, size: 18, color: Color(0xFF4F644B)),
        ),
        const SizedBox(width: 8),
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topRight: Radius.circular(4),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              color: const Color(0x99CFE6C7),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDot(_animation1),
                      const SizedBox(width: 4),
                      _buildDot(_animation2),
                      const SizedBox(width: 4),
                      _buildDot(_animation3),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF4F644B),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
