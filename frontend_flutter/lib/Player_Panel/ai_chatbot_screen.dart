import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/token_service.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../theme/colors.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isDarkMode = false;
  bool _botTyping = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hi! I am CourtWala AI 🤖\nHow can I help you?',
      'isUser': false,
      'type': 'AI',
      'time': DateTime.now(),
    },
  ];

  DateTime _safeDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {}
    }
    return DateTime.now();
  }

  // ================= SEND MESSAGE =================
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'type': 'USER',
        'time': DateTime.now(),
      });
      _botTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final isMyBookings = text.toLowerCase().contains('my booking');
      final token = await TokenService.getToken();

      if (isMyBookings && token == null) {
        await _typeBotMessage('Please log in to view your bookings.', 'AI');
        return;
      }

      final uri = isMyBookings
          ? Uri.parse('${ApiConstants.baseUrl}/chat/my-bookings')
          : Uri.parse('${ApiConstants.baseUrl}/chat');

      final headers = {
        'Content-Type': 'application/json',
        if (isMyBookings) 'Authorization': 'Bearer $token',
      };

      final res = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({'message': text}),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        await _typeBotMessage(
          body['reply'] ?? 'No response',
          body['type'] ?? 'AI',
        );
      } else {
        _addError();
      }
    } catch (_) {
      _addError();
    } finally {
      setState(() => _botTyping = false);
    }
  }

  // ================= BOT TYPING EFFECT =================
  Future<void> _typeBotMessage(String text, String type) async {
    final index = _messages.length;

    setState(() {
      _messages.add({
        'text': '',
        'isUser': false,
        'type': type,
        'time': DateTime.now(),
      });
    });

    for (int i = 0; i < text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 18));
      setState(() {
        _messages[index]['text'] += text[i];
      });
      _scrollToBottom();
    }
  }

  void _addError() {
    _messages.add({
      'text': '⚠️ AI service unavailable.',
      'isUser': false,
      'type': 'AI',
      'time': DateTime.now(),
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final bg = _isDarkMode ? const Color(0xFF0F1115) : const Color(0xFFF6F8FA);
    final userBubble = AppColors.primaryColor;
    final botBubble = _isDarkMode ? const Color(0xFF262A33) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: _isDarkMode ? Colors.black : AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'CourtWala AI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_botTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_botTyping && i == _messages.length) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(
                      '🤖 Typing...',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  );
                }

                final msg = _messages[i];
                final time = _safeDateTime(msg['time']);

                if (msg['type'] == 'DATA') {
                  return _dataCard(msg['text'], time);
                }

                final isUser = msg['isUser'] == true;

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: _chatBubble(
                    msg['text'],
                    time,
                    isUser,
                    userBubble,
                    botBubble,
                    textColor,
                  ),
                );
              },
            ),
          ),
          _inputBox(textColor),
        ],
      ),
    );
  }

  // ================= DATA CARD =================
  Widget _dataCard(String text, DateTime time) {
    final isDark = _isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2933) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              height: 1.5,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('hh:mm a').format(time),
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ================= CHAT BUBBLE =================
  Widget _chatBubble(
    String text,
    DateTime time,
    bool isUser,
    Color userBubble,
    Color botBubble,
    Color textColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUser ? userBubble : botBubble,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isUser
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isUser ? Colors.white : textColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('hh:mm a').format(time),
            style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // ================= INPUT BOX =================
  Widget _inputBox(Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Ask CourtWala AI...',
                hintStyle: TextStyle(
                  color: _isDarkMode ? Colors.grey.shade400 : Colors.grey,
                ),
                filled: true,
                fillColor: _isDarkMode ? const Color(0xFF1A1E27) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color:
                        _isDarkMode ? Colors.grey.shade700 : Colors.transparent,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color:
                        _isDarkMode ? Colors.grey.shade700 : Colors.transparent,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryColor,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
