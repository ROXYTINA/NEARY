import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:salon_beauty_app/app_theme/app_text_styles.dart';
import '../../app_state/notifiers.dart';
import '../../app_state/api_settings.dart';
import '../../app_widget/common_widget.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // Safely trigger data generation right when the widget mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshChatList();
      }
    });
  }

  void _refreshChatList() {
    // 1. Correct type matched to your notifier file class definition
    final apiSettings = context.read<ApiSettingsNotifier>(); 
    final bookingNotifier = context.read<BookingNotifier>();

    // 2. Gather both upcoming and past bookings to compute active conversations
    final allBookings = [
      ...bookingNotifier.upcomingBookings,
      ...bookingNotifier.pastBookings,
    ];

    // 3. Dispatch data down to your backend sync parser loops
    context.read<ChatNotifier>().loadUserThreads(apiSettings.baseUrl, allBookings);
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatNotifier>();
    final threads = chat.threads;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stylist Messages'),
        elevation: 0,
      ),
      body: chat.isLoading
          ? const Center(child: CircularProgressIndicator())
          : threads.isEmpty
              ? Center(
                  child: Text(
                    'No active conversations yet.',
                    style: AppTextStyles.displaySm.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _refreshChatList(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: threads.length,
                    itemBuilder: (context, i) {
                      final t = threads[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: NetworkAvatar(
                            imageUrl: t.stylistAvatar,
                            radius: 20,
                            icon: Icons.person,
                          ),
                          title: Text(
                            t.stylistName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            t.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: t.unreadCount > 0
                              ? CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.redAccent,
                                  child: Text(
                                    '${t.unreadCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            context.push('/chat/${t.stylistId}');
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}