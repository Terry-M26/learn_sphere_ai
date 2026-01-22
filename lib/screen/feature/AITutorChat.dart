import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learn_sphere_ai/controller/chat_controller.dart';
import 'package:learn_sphere_ai/helper/global.dart';
import 'package:learn_sphere_ai/helper/theme_provider.dart';
import 'package:learn_sphere_ai/screen/feature/ChatHistory_screen.dart';
import 'package:learn_sphere_ai/widget/message_card.dart';
import 'package:provider/provider.dart';

class AITutorChat extends StatefulWidget {
  const AITutorChat({super.key});

  @override
  State<AITutorChat> createState() => _AITutorChatState();
}

class _AITutorChatState extends State<AITutorChat>
    with TickerProviderStateMixin {
  final _c = ChatController();
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonAnimation;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _sendButtonAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _sendButtonController.dispose();
    super.dispose();
  }

  void _openChatHistory() async {
    await _c.saveConversation();
    if (!mounted) return;

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const ChatHistoryScreen()),
    );

    if (result != null) {
      _c.loadConversation(
        result['conversationId'] as String,
        result['messages'] as List<dynamic>,
      );
    }
  }

  void _startNewChat() async {
    await _c.saveConversation();
    _c.newConversation();
  }

  void _onSendPressed() async {
    await _sendButtonController.forward();
    await _sendButtonController.reverse();
    _c.askQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await _c.saveConversation();
        }
      },
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final isDark = themeProvider.isDarkMode;

          return Scaffold(
            backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
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
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_comment_outlined),
                  tooltip: 'New Chat',
                  onPressed: _startNewChat,
                ),
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'Chat History',
                  onPressed: _openChatHistory,
                ),
              ],
            ),

            //send message field button
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
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
                  //text input
                  Expanded(
                    child: TextFormField(
                      controller: _c.textC,
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        hintText: 'Ask me anything...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[400],
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
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

                  //adding some space
                  const SizedBox(width: 8),

                  //send button
                  ScaleTransition(
                    scale: _sendButtonAnimation,
                    child: Container(
                      decoration: BoxDecoration(
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
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: _onSendPressed,
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

            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [Colors.grey[900]!, Colors.grey[850]!]
                      : [Colors.grey[50]!, Colors.white],
                ),
              ),
              child: Obx(
                () => ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: mq.height * 0.02,
                    bottom: mq.height * 0.12,
                    left: 8,
                    right: 8,
                  ),
                  itemCount: _c.list.length,
                  itemBuilder: (context, index) {
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
