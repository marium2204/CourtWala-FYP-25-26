import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

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
      'time': DateTime.now(),
    },
  ];

  // =====================
  // SAFE DATETIME HANDLER
  // =====================
  DateTime _safeDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {}
    }
    return DateTime.now();
  }

  // =====================
  // SEND MESSAGE
  // =====================
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'time': DateTime.now(),
      });
      _botTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text}),
      );

      if (res.statusCode == 200) {
        final reply = jsonDecode(res.body)['reply'] ?? 'No response';
        await _typeBotMessage(reply);
      } else {
        _addError();
      }
    } catch (_) {
      _addError();
    } finally {
      setState(() => _botTyping = false);
    }
  }

  // =====================
  // TYPING ANIMATION
  // =====================
  Future<void> _typeBotMessage(String text) async {
    final index = _messages.length;

    setState(() {
      _messages.add({
        'text': '',
        'isUser': false,
        'time': DateTime.now(),
      });
    });

    for (int i = 0; i < text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 25));
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

  // =====================
  // UI
  // =====================
  @override
  Widget build(BuildContext context) {
    final bg = _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF7F3EE);
    final userBubble = _isDarkMode ? Colors.blueAccent : Colors.blue;
    final botBubble = _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: _isDarkMode ? Colors.black : Colors.blue,
        title: const Text(
          'CourtWala AI',
          style: TextStyle(
            color: Colors.white, // ✅ FIX: always visible
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() => _isDarkMode = !_isDarkMode);
            },
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
                  return Text(
                    '🤖 Typing...',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: textColor,
                    ),
                  );
                }

                final msg = _messages[i];
                final isUser = msg['isUser'] == true;
                final time = _safeDateTime(msg['time']);

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? userBubble : botBubble,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'],
                          style: TextStyle(color: textColor),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('hh:mm a').format(time),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            if (!isUser) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(text: msg['text']),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copied to clipboard'),
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.copy,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
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
                hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                filled: true,
                fillColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.send,
              color: _isDarkMode ? Colors.white : Colors.blue,
            ),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
