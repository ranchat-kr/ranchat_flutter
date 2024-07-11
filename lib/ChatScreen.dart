import 'package:ranchat_flutter/main.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreen createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> {
  final _messages = <String>[];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'chat',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
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
