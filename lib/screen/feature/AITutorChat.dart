// AITutorChat - main chat interface for AI Tutor feature
// Users can ask questions and receive AI-powered responses
// Features: chat history, new chat, conversation persistence

import 'package:flutter/material.dart';
import 'package:get/get.dart'; // For Obx reactive widget
import 'package:learn_sphere_ai/controller/chat_controller.dart'; // Chat state management
import 'package:learn_sphere_ai/helper/global.dart'; // For mq (screen size)
import 'package:learn_sphere_ai/helper/theme_provider.dart'; // Theme state
import 'package:learn_sphere_ai/helper/auth_helper.dart'; // Login check
import 'package:learn_sphere_ai/screen/feature/ChatHistory_screen.dart'; // History screen
import 'package:learn_sphere_ai/widget/message_card.dart'; // Message bubble widget
import 'package:provider/provider.dart'; // For Consumer widget

// StatefulWidget for managing animations and controller lifecycle
class AITutorChat extends StatefulWidget {
  const AITutorChat({super.key}); // Constructor

  @override
  State<AITutorChat> createState() => _AITutorChatState();
}

// TickerProviderStateMixin provides vsync for multiple animations
class _AITutorChatState extends State<AITutorChat>
    with TickerProviderStateMixin {
  final _c = ChatController(); // GetX controller for chat state
  late AnimationController _sendButtonController; // Send button press animation
  late Animation<double> _sendButtonAnimation; // Scale animation for button

  @override
  void initState() {
    super.initState();
    // Initialize send button animation controller
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    // Scale animation: 1.0 (normal) -> 0.9 (pressed) for button feedback
    _sendButtonAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // Clean up animation controller to prevent memory leaks
    _sendButtonController.dispose();
    super.dispose();
  }

  // Open chat history screen - requires login
  void _openChatHistory() async {
    // Check if user is logged in - show login dialog if not
    if (!AuthHelper.isLoggedIn) {
      final loggedIn = await AuthHelper.showLoginRequiredDialog(
        context,
        featureName: 'Chat History',
      );
      if (!loggedIn || !mounted) return; // User cancelled or widget disposed
    }

    // Save current conversation before viewing history
    await _c.saveConversation();
    if (!mounted) return;

    // Navigate to history screen and wait for result
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const ChatHistoryScreen()),
    );

    // If user selected a conversation, load it
    if (result != null) {
      _c.loadConversation(
        result['conversationId'] as String,
        result['messages'] as List<dynamic>,
      );
    }
  }

  // Start a new chat - saves current and clears messages
  void _startNewChat() async {
    await _c.saveConversation(); // Save current conversation first
    _c.newConversation(); // Clear messages and start fresh
  }

  // Handle send button press with animation
  void _onSendPressed() async {
    await _sendButtonController.forward(); // Scale down
    await _sendButtonController.reverse(); // Scale back up
    _c.askQuestion(); // Send question to AI
  }

  @override
  Widget build(BuildContext context) {
    // PopScope handles back button - saves conversation before leaving
    return PopScope(
      canPop: true, // Allow back navigation
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await _c.saveConversation(); // Auto-save on exit
        }
      },
      // Consumer rebuilds when theme changes
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final isDark = themeProvider.isDarkMode;

          return Scaffold(
            backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
            // Gradient AppBar with actions
            appBar: AppBar(
              title: const Text(
                'AI Tutor Chat',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              // Purple gradient background for AppBar
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
              // Action buttons: New Chat and History
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_comment_outlined),
                  tooltip: 'New Chat',
                  onPressed: _startNewChat, // Start new conversation
                ),
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'Chat History',
                  onPressed: _openChatHistory, // View saved conversations
                ),
              ],
            ),

            // Message input field positioned at bottom center
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              // Rounded container for input field
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Text input field - expands to fill available space
                  Expanded(
                    child: TextFormField(
                      controller: _c.textC, // Controller from ChatController
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        hintText: 'Ask me anything...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[400],
                          fontSize: 16,
                        ),
                        border: InputBorder.none, // No border
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8), // Spacing
                  // Send button with scale animation on press
                  ScaleTransition(
                    scale: _sendButtonAnimation, // Animated scale
                    child: Container(
                      decoration: BoxDecoration(
                        // Purple gradient matching AppBar
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      // Material + InkWell for ripple effect
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: _onSendPressed, // Send message
                          child: Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Chat messages body
            body: Container(
              decoration: BoxDecoration(
                // Subtle gradient background
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [Colors.grey[900]!, Colors.grey[850]!]
                      : [Colors.grey[50]!, Colors.white],
                ),
              ),
              // Obx rebuilds when _c.list changes (GetX reactive)
              child: Obx(
                () => ListView.builder(
                  physics: const BouncingScrollPhysics(), // iOS-style bounce
                  padding: EdgeInsets.only(
                    top: mq.height * 0.02,
                    bottom: mq.height * 0.12, // Space for input field
                    left: 8,
                    right: 8,
                  ),
                  itemCount: _c.list.length, // Number of messages
                  itemBuilder: (context, index) {
                    // Each message with staggered animation
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      curve: Curves.easeOutBack,
                      child: MessageCard(message: _c.list[index]),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
