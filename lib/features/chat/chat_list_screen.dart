import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state/notifiers.dart';
import '../../app_widget/common_widget.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
	final chat = context.watch<ChatNotifier>();
	final threads = chat.threads;

	return Scaffold(
	  appBar: AppBar(title: const Text('Chat')),
	  body: ListView.builder(
		padding: const EdgeInsets.all(16),
		itemCount: threads.length,
		itemBuilder: (_, i) {
		  final t = threads[i];
		  return ListTile(
			leading: NetworkAvatar(
			  imageUrl: t.salonAvatar,
			  radius: 20,
			  icon: Icons.storefront,
			),
			title: Text(t.salonName),
			subtitle: Text(t.lastMessage),
			trailing: t.unreadCount > 0 ? CircleAvatar(radius: 10, child: Text('${t.unreadCount}')) : null,
			onTap: () => Navigator.pushNamed(context, '/chat/${t.salonId}'),
		  );
		},
	  ),
	);
  }
}


