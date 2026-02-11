// MessageCard widget - displays a single chat message in AI Tutor
// Handles both user messages (right-aligned) and bot messages (left-aligned)
// Includes slide-in animation when message appears

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For user profile photo
import 'package:learn_sphere_ai/helper/global.dart'; // For mq (screen size)
import 'package:learn_sphere_ai/helper/theme_provider.dart'; // For dark/light mode
import 'package:learn_sphere_ai/model/message.dart'; // Message model
import 'package:provider/provider.dart'; // For Consumer widget

// StatefulWidget because it manages animation state
class MessageCard extends StatefulWidget {
  final Message message; // The message data to display
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

// State class with SingleTickerProviderStateMixin for animations
// SingleTickerProviderStateMixin provides vsync for smooth 60fps animations
class _MessageCardState extends State<MessageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController; // Controls animation timing
  late Animation<double> _slideAnimation; // Horizontal slide effect
  late Animation<double> _fadeAnimation; // Opacity fade-in effect

  @override
  void initState() {
    super.initState();
    // Initialize animation controller with 600ms duration
    // vsync: this prevents animations when widget not visible
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Slide animation: bot messages slide from left (-50), user from right (+50)
    _slideAnimation =
        Tween<double>(
          begin: widget.message.msgType == MessageType.bot ? -50.0 : 50.0,
          end: 0.0, // End at normal position
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack, // Slight overshoot for bounce effect
          ),
        );

    // Fade animation: 0 (invisible) to 1 (fully visible)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start animation after widget is built
    // addPostFrameCallback ensures widget is mounted before animating
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward(); // Play animation forward
    });
  }

  @override
  void dispose() {
    // IMPORTANT: Always dispose animation controllers to prevent memory leaks
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Radius for message bubble corners
    const r = Radius.circular(20);

    // Consumer listens to theme changes for dark/light mode styling
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // AnimatedBuilder rebuilds on every animation frame
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            // Apply slide and fade animations
            return Transform.translate(
              offset: Offset(_slideAnimation.value, 0), // Horizontal slide
              child: Opacity(
                opacity: _fadeAnimation.value, // Fade effect
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  // Show different layout based on message sender
                  child: widget.message.msgType == MessageType.bot
                      ? _buildBotMessage(r, themeProvider.isDarkMode)
                      : _buildUserMessage(r, themeProvider.isDarkMode),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Build bot (AI) message - left-aligned with Albert avatar
  Widget _buildBotMessage(Radius r, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end, // Align avatar to bottom
      children: [
        const SizedBox(width: 8), // Left padding
        // AI avatar with gradient background and shadow
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Container(
              decoration: const BoxDecoration(
                // Purple gradient background for AI avatar
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                shape: BoxShape.circle,
              ),
              // Albert AI tutor image
              child: Image.asset(
                'assets/images/Albert.png',
                width: 40,
                height: 40,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Message bubble - flexible width up to 70% of screen
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: mq.width * 0.7),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              // Theme-aware background color
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              // Rounded corners with small corner at bottom-left (speech bubble effect)
              borderRadius: BorderRadius.only(
                topLeft: r,
                topRight: r,
                bottomRight: r,
                bottomLeft: const Radius.circular(4), // Small corner
              ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            // Message text with theme-aware color
            child: Text(
              widget.message.msg,
              style: TextStyle(
                fontSize: 15,
                color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
                height: 1.4, // Line height for readability
              ),
            ),
          ),
        ),
        const SizedBox(width: 50), // Right padding to offset from edge
      ],
    );
  }

  // Build user message - right-aligned with user avatar
  Widget _buildUserMessage(Radius r, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end, // Align to right side
      children: [
        const SizedBox(width: 50), // Left padding to offset from edge
        // Message bubble with gradient background
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: mq.width * 0.7),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              // Purple gradient for user messages
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              // Rounded corners with small corner at bottom-right
              borderRadius: BorderRadius.only(
                topLeft: r,
                topRight: r,
                bottomLeft: r,
                bottomRight: const Radius.circular(4), // Small corner
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            // White text on gradient background
            child: Text(
              widget.message.msg,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // User avatar with shadow
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          // StreamBuilder listens to auth state for user photo
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data; // Current Firebase user

              // Display user's Google profile photo or default icon
              return CircleAvatar(
                radius: 20,
                backgroundColor: isDarkMode
                    ? Colors.grey[600]
                    : Colors.grey[300],
                // Show Google profile photo if available
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                // Show person icon if no photo
                child: user?.photoURL == null
                    ? const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 30,
                      )
                    : null,
              );
            },
          ),
        ),
        const SizedBox(width: 8), // Right padding
      ],
    );
  }
}
