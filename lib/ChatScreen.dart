import 'package:ranchat_flutter/ConnectingService.dart';
import 'package:flutter/material.dart';
import 'Message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreen createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> {
  final _messages = <Message>[];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  late Connectingservice _connectingservice;

  var isMe = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode.requestFocus();
    _connectingservice = Connectingservice();
    _connectingservice.connectToWebSocket();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _connectingservice.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String message) {
    print('chatScreen send message: $message');
    _connectingservice.sendMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
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
            'Chat',
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
                      _messages[index].message,
                      style: TextStyle(color: _messages[index].color),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isMe = !isMe;
                      });
                    },
                    child: Icon(
                      isMe
                          ? Icons.keyboard_arrow_right
                          : Icons.keyboard_arrow_left,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      style: const TextStyle(color: Colors.white),
                      controller: _textController,
                      decoration: const InputDecoration(
                          hintText: '입력하세요.',
                          hintStyle: TextStyle(color: Colors.white60),
                          border: InputBorder.none),
                      cursorColor: Colors.white,
                      cursorWidth: 8.0,
                      cursorRadius: Radius.zero,
                      onSubmitted: (value) {
                        final message = _textController.text.trim();
                        if (message.isNotEmpty) {
                          setState(() {
                            _messages.add(Message(
                                message: message,
                                color: isMe ? Colors.yellow : Colors.white));
                            _textController.clear();
                            _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.fastEaseInToSlowEaseOut);
                          });
                          _sendMessage(message);
                        }
                        FocusScope.of(context).requestFocus(_focusNode);
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      final message = _textController.text.trim();
                      if (message.isNotEmpty) {
                        setState(() {
                          _messages.add(Message(
                              message: message,
                              color: isMe ? Colors.yellow : Colors.white));
                          _textController.clear();
                          _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.fastEaseInToSlowEaseOut);
                        });
                        _sendMessage(message);
                      }
                      FocusScope.of(context).requestFocus(_focusNode);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.yellow,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                          side: const BorderSide(
                              color: Colors.yellow, width: 2.0)),
                    ),
                    child: const Text('보내기'),
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
