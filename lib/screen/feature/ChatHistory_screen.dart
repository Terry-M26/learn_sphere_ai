// ChatHistoryScreen - View and manage saved AI Tutor conversations
// Displays list of past conversations with timestamps
// Features: load previous conversation, delete conversations, real-time updates
// Requires authentication to access

import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore streams
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:learn_sphere_ai/helper/auth_helper.dart'; // For login check
import 'package:learn_sphere_ai/helper/theme_provider.dart'; // For theme
import 'package:learn_sphere_ai/service/database.dart'; // For Firestore operations
import 'package:provider/provider.dart'; // For Consumer widget

// StatefulWidget to manage conversation list stream
class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key}); // Constructor

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  Stream<QuerySnapshot>? _conversationsStream;
  final DatabaseMethods _db = DatabaseMethods();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoad();
  }

  void _checkAuthAndLoad() {
    if (!AuthHelper.isLoggedIn) {
      // Should not happen as we check before navigating, but handle gracefully
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return;
    }
    _userId = AuthHelper.userId;
    setState(() {
      _conversationsStream = _db.getConversations(_userId!);
    });
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final date = timestamp.toDate();
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }

  Future<void> _deleteConversation(String conversationId) async {
    if (_userId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text(
          'Are you sure you want to delete this conversation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _db.deleteConversation(_userId!, conversationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
          appBar: AppBar(
            title: const Text(
              'Chat History',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: _conversationsStream == null
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<QuerySnapshot>(
                  stream: _conversationsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading conversations',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: isDark
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No conversations yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start chatting with AI Tutor!',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final timestamp = data['updatedAt'] as Timestamp?;
                        final messages =
                            data['messages'] as List<dynamic>? ?? [];

                        // Get preview from first user message
                        String preview = 'Empty conversation';
                        for (var msg in messages) {
                          if (msg['msgType'] == 'user') {
                            preview = msg['msg'] ?? '';
                            if (preview.length > 50) {
                              preview = '${preview.substring(0, 50)}...';
                            }
                            break;
                          }
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: isDark ? Colors.grey[800] : Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.chat,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              'Chat - ${_formatTimestamp(timestamp)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                preview,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              onPressed: () => _deleteConversation(doc.id),
                            ),
                            onTap: () {
                              Navigator.pop(context, {
                                'conversationId': doc.id,
                                'messages': messages,
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}
