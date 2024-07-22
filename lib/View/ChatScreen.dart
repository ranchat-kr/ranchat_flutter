import 'package:ranchat_flutter/ViewModel/ConnectingService.dart';
import 'package:flutter/material.dart';
import 'package:ranchat_flutter/Model/MessageData.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreen createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> {
  late List<MessageData> _messageDatas = <MessageData>[];
  //late List<MessageData> _tempMessageDatas = <MessageData>[];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  late Connectingservice _connectingservice;

  var isMe = true;
  var _isLoading = false;
  var _page = 0;
  final _pageSize = 20;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('_meesageDatas length: ${_messageDatas.length}');
    _focusNode.requestFocus();
    _connectingservice = Connectingservice(
      onMessageReceivedCallback: _onMessageReceived,
    );
    _connectingservice.connectToWebSocket();
    _getMessages();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 20 &&
          !_isLoading) {
        print('messageDatas length : ${_messageDatas.length}, page : $_page');
        if (_messageDatas.length == (_page + 1) * _pageSize &&
            _messageDatas.length < _connectingservice.messageList.totalCount) {
          _fetchItems();
        }
      }
    });
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

  void _onMessageReceived(MessageData messageData) {
    print('chatScreen onMessageReceived: $messageData');

    setState(() {
      _messageDatas.insert(0, messageData);
      _scrollController.animateTo(_scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastEaseInToSlowEaseOut);
    });
  }

  void _getMessages() async {
    final messages = await _connectingservice.getMessages(
        page: _page++, size: _pageSize * 2);

    setState(() {
      print('page : $_page');
      _messageDatas = messages;
    });
  }

  Future<void> _fetchItems() async {
    final messages =
        await _connectingservice.getMessages(page: ++_page, size: _pageSize);
    setState(() {
      print('page : $_page');
      _isLoading = true;
      _messageDatas.addAll(messages);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          resizeToAvoidBottomInset: true,
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
              highlightColor: Colors.grey,
            ),
            title: const Text(
              'Chat',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.report,
                  color: Colors.white,
                ),
                onPressed: () {
                  print('report');
                },
                highlightColor: Colors.grey,
              ),
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                onPressed: () {
                  print('out');
                },
                highlightColor: Colors.grey,
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                      child: Align(
                    alignment: Alignment.topCenter,
                    child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      reverse: true,
                      itemCount: _messageDatas.isEmpty
                          ? 0
                          : _messageDatas.length ==
                                  _connectingservice.messageList.totalCount
                              ? _messageDatas.length
                              : _messageDatas.length - _pageSize,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Text(
                            "${_connectingservice.userId == _messageDatas[index].userId ? '나' : '상대방'}: ${_messageDatas[index].content}",
                            style: TextStyle(
                                color: _connectingservice.userId1 ==
                                        _messageDatas[index].userId
                                    ? Colors.yellow
                                    : Colors.white),
                          ),
                        );
                      },
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            print('now user : ${_connectingservice.userId}');
                            _connectingservice.changeUser();
                          },
                          child: const Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            focusNode: _focusNode,
                            style: const TextStyle(color: Colors.white),
                            controller: _textController,
                            decoration: const InputDecoration(
                                hintText: ' 입력하세요.',
                                hintStyle: TextStyle(color: Colors.white60),
                                border: InputBorder.none),
                            cursorColor: Colors.white,
                            cursorWidth: 8.0,
                            cursorRadius: Radius.zero,
                            onSubmitted: (value) {
                              final message = _textController.text.trim();
                              if (message.isNotEmpty) {
                                setState(() {
                                  // _messageDatas.add(MessageData(
                                  //     message: message,
                                  //     color: isMe ? Colors.yellow : Colors.white));
                                  _textController.clear();
                                  _scrollController.animateTo(
                                      _scrollController
                                          .position.minScrollExtent,
                                      duration:
                                          const Duration(milliseconds: 300),
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
                                // _messages.add(Message(
                                //     message: message,
                                //     color: isMe ? Colors.yellow : Colors.white));
                                _textController.clear();
                                _scrollController.animateTo(
                                    _scrollController.position.minScrollExtent,
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
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          )),
    );
  }
}
