// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:ranchat_flutter/Model/MessageData.dart';
import 'package:ranchat_flutter/ViewModel/ConnectingService.dart';

class ChatScreen extends StatefulWidget {
  final Connectingservice connectingservice;
  const ChatScreen({
    super.key,
    required this.connectingservice,
  });

  @override
  _ChatScreen createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> {
  late List<MessageData> _messageDatas = <MessageData>[];
  //late List<MessageData> _tempMessageDatas = <MessageData>[];
  final _textController = TextEditingController();
  final _dialogTextController = TextEditingController();
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
    _connectingservice = widget.connectingservice;
    _focusNode.requestFocus();
    _connectingservice = Connectingservice(
      onMessageReceivedCallback: _onMessageReceived,
      onMatchingSuccess: (response) {},
    );
    _connectingservice.onMessageReceivedCallback = _onMessageReceived;
    _connectingservice.connectToWebSocket();
    _getMessages();
    _scrollController.addListener(() {
      print(
          '_scrollController.position.pixels: ${_scrollController.position.pixels}, _scrollController.position.maxScrollExtent: ${_scrollController.position.maxScrollExtent}');
      if (_scrollController.position.pixels <=
              _scrollController.position.maxScrollExtent - 30 &&
          !_isLoading) {
        print('messageDatas length : ${_messageDatas.length}, page : $_page');
        if (_messageDatas.length >= (_page + 1) * _pageSize &&
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

  void _showReportDialog() {
    final List<String> reportReasons = [
      '스팸',
      '욕설 및 비방',
      '허위 정보',
      '저작권 침해',
      '기타',
    ];
    String? selectedReason;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('신고'),
            scrollable: true,
            content: Column(
              children: [
                DropdownButtonFormField(
                  value: selectedReason,
                  items: reportReasons.map((reason) {
                    return DropdownMenuItem(
                      value: reason,
                      child: Text(reason),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedReason = newValue;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: '신고 사유 선택',
                  ),
                ),
                TextField(
                  minLines: 1,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.black),
                  controller: _dialogTextController,
                  decoration: const InputDecoration(
                      hintText: ' 신고 내용을 입력하세요.',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none),
                  cursorColor: Colors.grey,
                  cursorWidth: 8.0,
                  cursorRadius: Radius.zero,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  if (selectedReason == null) {
                    return;
                  } else {
                    final report = _dialogTextController.text.trim();

                    print('신고 완료. $selectedReason / $report');
                    Navigator.pop(context);
                  }
                },
                child: const Text('신고'),
              )
            ],
          );
        });
  }

  void _showOutDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('나가기'),
            content: const Text('채팅방을 나가시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('나가기'),
              )
            ],
          );
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
                  _showReportDialog();
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
                  _showOutDialog();
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
                      padding: const EdgeInsets.only(bottom: 0.0),
                      controller: _scrollController,
                      shrinkWrap: true,
                      reverse: true,
                      itemCount: _messageDatas.isEmpty
                          ? 0
                          : _messageDatas.length >=
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
                                  : Colors.white,
                            ),
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
                            minLines: 1,
                            maxLines: 3,
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
