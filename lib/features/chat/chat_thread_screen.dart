// chat_thread_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salon_beauty_app/app_model/chat.dart';
import 'package:salon_beauty_app/app_theme/app_text_styles.dart';
import '../../app_state/notifiers.dart';
import '../../app_state/api_settings.dart';

class ChatThreadScreen extends StatefulWidget {
  final String stylistId;
  const ChatThreadScreen({super.key, required this.stylistId});

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncMessages();
      }
    });
  }

  void _syncMessages() {
    final baseUrl = context.read<ApiSettingsNotifier>().baseUrl;
    final currentUserId = context.read<AuthNotifier>().email ?? 'guest_user';

    context.read<ChatNotifier>().syncMessageLogs(baseUrl, widget.stylistId, currentUserId);
  }
@override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatNotifier>();
    final messages = chat.getMessages(widget.stylistId);

    final baseUrl = context.watch<ApiSettingsNotifier>().baseUrl;
    final currentUserId = context.watch<AuthNotifier>().email ?? 'guest_user';

    final currentThread = chat.threads.firstWhere(
      (t) => t.stylistId == widget.stylistId,
      orElse: () => ChatThread(
        stylistId: widget.stylistId,
        stylistName: 'Stylist',
        stylistAvatar: '',
        lastMessage: '',
        lastTime: DateTime.now(), 
        unreadCount: 0,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentThread.stylistName, 
          style: AppTextStyles.displaySm.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final m = messages[i];
                return Align(
                  alignment: m.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: m.isMe ? Colors.blueAccent : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(color: m.isMe ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          if (chat.isTyping(widget.stylistId)) 
            const Padding(
              padding: EdgeInsets.all(8), 
              child: Text('Stylist is typing...'),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl, 
                      decoration: const InputDecoration(hintText: 'Type a message...'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final text = _ctrl.text.trim();
                      if (text.isNotEmpty) {
                        context.read<ChatNotifier>().sendMessage(
                          widget.stylistId, 
                          text, 
                          currentUserId, 
                          baseUrl,
                        );
                        _ctrl.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}