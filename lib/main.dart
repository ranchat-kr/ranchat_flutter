import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '',
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messages = <String>[];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '임재와 문장이의 은밀한 채팅 흐흐흐~~😘',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    _messages[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.white,
                ),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: _textController,
                    decoration: const InputDecoration(
                        hintText: '입력하세요.',
                        hintStyle: TextStyle(color: Colors.white60),
                        border: InputBorder.none),
                    cursorColor: Colors.white,
                    cursorWidth: 1,
                    cursorHeight: 12,
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    final message = _textController.text.trim();
                    if (message.isNotEmpty) {
                      setState(() {
                        _messages.add(message);
                        _textController.clear();
                        _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.fastEaseInToSlowEaseOut);
                      });
                    }
                  },
                  child: const Text('보내기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
