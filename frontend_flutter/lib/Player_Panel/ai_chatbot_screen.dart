// lib/Player_Panel/chatbot_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Sample messages: true = user, false = bot
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hi! How can I help you today?',
      'isUser': false,
      'time': DateTime.now(),
    },
  ];

  bool _botTyping = false;

  // Quick reply options
  final List<Map<String, String>> _quickReplies = [
    {'label': 'Book a court', 'page': 'player_home'},
    {'label': 'View my bookings', 'page': 'my_bookings'},
    {'label': 'Challenges', 'page': 'challenges'},
  ];

  void _sendMessage({String? text}) async {
    final messageText = text ?? _controller.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _messages.add({
        'text': messageText,
        'isUser': true,
        'time': DateTime.now(),
      });
      _botTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    // Simulate bot response
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _messages.add({
        'text': _generateBotResponse(messageText),
        'isUser': false,
        'time': DateTime.now(),
      });
      _botTyping = false;
    });

    _scrollToBottom();

    // Navigate if quick reply directs to a page
    final reply = _quickReplies.firstWhere(
        (r) => r['label']!.toLowerCase() == messageText.toLowerCase(),
        orElse: () => {});
    if (reply.isNotEmpty) {
      _navigateToPage(reply['page']!);
    }
  }

  String _generateBotResponse(String userMsg) {
    // Replace with real chatbot logic
    switch (userMsg.toLowerCase()) {
      case 'book a court':
        return 'Sure! Redirecting you to book a court...';
      case 'view my bookings':
        return 'Here are your upcoming bookings.';
      case 'challenges':
        return 'Check out available challenges!';
      default:
        return 'I\'m here to help! You can say "Book a court", "View my bookings", or "Challenges".';
    }
  }

  void _navigateToPage(String page) {
    // Replace with your navigation logic
    if (page == 'player_home') {
      Navigator.pushNamed(context, '/player_home');
    } else if (page == 'my_bookings') {
      Navigator.pushNamed(context, '/my_bookings');
    } else if (page == 'challenges') {
      Navigator.pushNamed(context, '/challenges');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "CourtWala Chatbot",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length + (_botTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_botTyping && index == _messages.length) {
                    // Typing indicator
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryColor,
                          child: const Icon(Icons.smart_toy_outlined,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text('Typing...',
                              style: TextStyle(
                                  fontSize: 14, fontStyle: FontStyle.italic)),
                        ),
                      ],
                    );
                  }

                  final msg = _messages[index];
                  final isUser = msg['isUser'] as bool;
                  final DateTime time =
                      msg['time'] as DateTime? ?? DateTime.now();

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!isUser)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, top: 4),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primaryColor,
                            child: const Icon(Icons.smart_toy_outlined,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      Flexible(
                        child: Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.6),
                            child: Column(
                              crossAxisAlignment: isUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? AppColors.primaryColor
                                        : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft:
                                          Radius.circular(isUser ? 16 : 4),
                                      bottomRight:
                                          Radius.circular(isUser ? 4 : 16),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    msg['text'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isUser
                                          ? Colors.white
                                          : AppColors.headingBlue,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('hh:mm a').format(time),
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (isUser) const SizedBox(width: 8),
                      if (isUser)
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey,
                          child:
                              Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                    ],
                  );
                },
              ),
            ),

            // Quick replies
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _quickReplies.map((reply) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _sendMessage(text: reply['label']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      child: Text(
                        reply['label']!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Input box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
