import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state/notifiers.dart';

class ChatThreadScreen extends StatefulWidget {
  final String salonId;
  const ChatThreadScreen({super.key, required this.salonId});

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatNotifier>();
    final messages = chat.getMessages(widget.salonId);

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
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
                    child: Text(m.text),
                  ),
                );
              },
            ),
          ),
          if (chat.isTyping(widget.salonId)) const Padding(padding: EdgeInsets.all(8), child: Text('Salon is typing...')),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'Type a message')),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final text = _ctrl.text.trim();
                      if (text.isNotEmpty) {
                        context.read<ChatNotifier>().sendMessage(widget.salonId, text);
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
}

