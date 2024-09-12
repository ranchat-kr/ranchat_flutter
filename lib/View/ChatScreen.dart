import 'package:flutter/material.dart';
import 'package:ran_talk/Model/MessageData.dart';
import 'package:ran_talk/Model/RoomDetailData.dart';
import 'package:ran_talk/Service/ConnectingService.dart';

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
  late List<MessageData> _messageDatas = <MessageData>[]; // 메시지 데이터
  //late List<MessageData> _tempMessageDatas = <MessageData>[];
  final _textController = TextEditingController(); // 채팅 텍스트 컨트롤러
  final _dialogTextController = TextEditingController(); // 다이얼로그 텍스트 컨트롤러
  final _scrollController = ScrollController(); // 채팅 스크롤 컨트롤러
  final _focusNode = FocusNode(); // 포커스 노드 (텍스트 필드 포커스 관리를 위한 변수)
  late Connectingservice
      _connectingservice; // API, WebSocket 연결을 위한 객체 (main에서 받아옴)
  RoomDetailData _roomDetailData =
      RoomDetailData(id: 0, title: '', type: '', participants: []); // 채팅방 상세 정보

  var _isLoading = false; // 로딩 중인지 확인하는 변수
  var _currentPage = 0; // 현재 페이지 (메시지 데이터)
  final _pageSize = 50; // 메시지 데이터 페이지 사이즈

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setServer();
    _setUI();
    _getMessages();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // #region first setting
  // 웹소켓 설정
  void _setServer() {
    _connectingservice = widget.connectingservice;
    _connectingservice.websocketService
        ?.setOnMessageReceivedCallback(_onMessageReceived);
    getRoomDetailData();
  }

  // UI 설정
  void _setUI() {
    _focusNode.requestFocus(); // 텍스트 필드 포커스 설정
    _scrollController.addListener(() {
      // 스크롤 컨트롤러 설정
      print(
          '_scrollController.position.pixels: ${_scrollController.position.pixels}, _scrollController.position.maxScrollExtent: ${_scrollController.position.maxScrollExtent}');
      if (_scrollController.position.pixels <=
              _scrollController.position.maxScrollExtent - 30 &&
          !_isLoading) {
        // 스크롤이 끝에서 -30에 도달하면
        print(
            'messageDatas length : ${_messageDatas.length}, page : $_currentPage');
        if (_messageDatas.length >= (_currentPage + 1) * _pageSize &&
            _messageDatas.length <
                _connectingservice.apiService!.messageList.totalCount) {
          // 기준 데이터에 맞으면 업데이트
          _fetchItems();
        }
      }
    });
  }
  // #endregion

  // #region communicate with server
  // 메시지 전송
  void _sendMessage(String message) {
    print('chatScreen send message: $message');
    _connectingservice.websocketService?.sendMessage(message);
  }

  // 메시지 수신 (구독한 것에서)
  void _onMessageReceived(MessageData messageData) {
    print('chatScreen onMessageReceived: $messageData');

    setState(() {
      _messageDatas.insert(0, messageData); // 맨 앞에 데이터 추가
      _scrollController.animateTo(_scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastEaseInToSlowEaseOut);
    });
  }

  // 메시지 데이터 가져오기 (화면 처음 열릴 때)
  void _getMessages() async {
    final messages = await _connectingservice.apiService
        ?.getMessages(page: _currentPage++, size: _pageSize * 2);

    setState(() {
      print('page : $_currentPage');
      _messageDatas = messages!;
    });
  }

  // 메시지 데이터 추가 가져오기 (스크롤이 끝에 도달할 때) (API) [페이지네이션]
  Future<void> _fetchItems() async {
    final messages = await _connectingservice.apiService
        ?.getMessages(page: ++_currentPage, size: _pageSize);
    setState(() {
      print('page : $_currentPage');
      _isLoading = true;
      _messageDatas.addAll(messages!);
      _isLoading = false;
    });
  }

  // 채팅방 상세 정보 가져오기
  void getRoomDetailData() async {
    final roomDetail = await _connectingservice.apiService?.getRoomDetail();
    setState(() {
      _roomDetailData = roomDetail!;
    });
  }

  // 채팅방 나가기
  void exitRoom() async {
    // _connectingservice.apiService?.exitRoom();
    try {
      await _connectingservice.websocketService?.exitRoom();
      var isRoomExist = await _connectingservice.apiService?.checkRoomExist();
      _connectingservice.isRoomExist = isRoomExist!;
      Navigator.popUntil(context, (route) => route.isFirst); // 처음 화면으로 이동
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('서버와의 연결에 실패했습니다.'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // 메시지 수신 구독 취소
  void unSubscribeToRecieveMessage() async {
    _connectingservice.websocketService?.unSubscribeToRecieveMessage();
  }

  void reportUser(String selectedReason, String report) async {
    try {
      await _connectingservice.apiService?.reportUser(
          _roomDetailData.participants
              .firstWhere(
                  (element) => element.userId != _connectingservice.userId)
              .userId,
          selectedReason,
          report);
      print('신고 완료. $selectedReason / $report');
      _dialogTextController.clear();
      Navigator.pop(context);
    } catch (e) {
      _dialogTextController.clear();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('서버와 연결에 실패했습니다.'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
  // #endregion

  // #region dialog
  // 신고 다이얼로그
  void _showReportDialog() {
    final List<String> reportReasons = [
      '스팸',
      '욕설 및 비방',
      '광고',
      '허위 정보',
      '저작권 침해',
      '기타',
    ];
    String? selectedReason;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: AlertDialog(
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
                      const SizedBox(height: 20.0),
                      TextField(
                        minLines: 1,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.black),
                        controller: _dialogTextController,
                        decoration: const InputDecoration(
                            hintText: ' 신고 내용을 입력하세요.',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey, style: BorderStyle.solid),
                            )),
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
                        final report = _dialogTextController.text.trim();
                        if (selectedReason == null || report.isEmpty) {
                          return;
                        } else {
                          reportUser(selectedReason!, report);
                        }
                      },
                      child: const Text('신고'),
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  // 나가기 다이얼로그
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
                  setState(() {
                    _isLoading = true;
                    exitRoom();
                    _isLoading = false;
                  });
                },
                child: const Text('나가기'),
              )
            ],
          );
        });
  }
  // #endregion

  // #region UI
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
                setState(() {
                  _isLoading = true;
                  unSubscribeToRecieveMessage();
                  _isLoading = false;
                });
                Navigator.pop(context);
              },
              highlightColor: Colors.grey,
            ),
            title: Text(
              _roomDetailData.title,
              style: const TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            actions: <Widget>[
              _roomDetailData.type == "GPT"
                  ? Container()
                  : IconButton(
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
                    child: ScrollbarTheme(
                      data: ScrollbarThemeData(
                        thumbColor: WidgetStateProperty.all(Colors.white),
                        thumbVisibility: WidgetStateProperty.all(true),
                      ),
                      child: Scrollbar(
                        controller: _scrollController,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 0.0),
                          controller: _scrollController,
                          shrinkWrap: true,
                          reverse: true,
                          itemCount: _messageDatas.isEmpty
                              ? 0
                              : _messageDatas.length >=
                                      _connectingservice
                                          .apiService!.messageList.totalCount
                                  ? _messageDatas.length
                                  : _messageDatas.length - _pageSize,
                          itemBuilder: (context, index) {
                            String content;
                            if (_messageDatas[index].messageType == "ENTER") {
                              content = _messageDatas[index].content;
                            } else if (_messageDatas[index].messageType ==
                                "LEAVE") {
                              content = _messageDatas[index].content;
                            } else {
                              content =
                                  '${_messageDatas[index].userId == _connectingservice.userId ? '나' : '상대방'}: ${_messageDatas[index].content}';
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Text(
                                content,
                                style: TextStyle(
                                  color: _messageDatas[index].messageType ==
                                          "ENTER"
                                      ? Colors.cyan
                                      : _messageDatas[index].messageType ==
                                              "LEAVE"
                                          ? Colors.red
                                          : _connectingservice.userId ==
                                                  _messageDatas[index].userId
                                              ? Colors.yellow
                                              : Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            print('now user : ${_connectingservice.userId}');
                            // _connectingservice. changeUser();
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
                            // onSubmitted: (value) {
                            //   final message = _textController.text.trim();
                            //   if (message.isNotEmpty) {
                            //     setState(() {
                            //       // _messageDatas.add(MessageData(
                            //       //     message: message,
                            //       //     color: isMe ? Colors.yellow : Colors.white));
                            //       _textController.clear();
                            //       _scrollController.animateTo(
                            //           _scrollController
                            //               .position.minScrollExtent,
                            //           duration:
                            //               const Duration(milliseconds: 300),
                            //           curve: Curves.fastEaseInToSlowEaseOut);
                            //     });
                            //     _sendMessage(message);
                            //   }
                            //   FocusScope.of(context).requestFocus(_focusNode);
                            // },
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
// #endregion