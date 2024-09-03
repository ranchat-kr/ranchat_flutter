// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ranchat_flutter/src/Model/MessageData.dart';
import 'package:ranchat_flutter/src/Model/RoomDetailData.dart';
import 'package:ranchat_flutter/src/Service/message_service.dart';
import 'package:ranchat_flutter/src/Service/room_service.dart';
import 'package:ranchat_flutter/src/Service/user_service.dart';
import 'package:ranchat_flutter/src/Service/websocket_service.dart';
import 'package:ranchat_flutter/src/View/base_view_model.dart';

class ChatViewModel extends BaseViewModel {
  final textController = TextEditingController(); // 채팅 텍스트 컨트롤러
  final dialogTextController = TextEditingController(); // 다이얼로그 텍스트 컨트롤러
  final scrollController = ScrollController(); // 채팅 스크롤 컨트롤러
  final focusNode = FocusNode(); // 포커스 노드 (텍스트 필드 포커스 관리를 위한 변수)

  final MessageService messageService; // 채팅 메시지 서비스
  final RoomService roomService; // 채팅방 서비스
  final WebsocketService websocketService; // 웹소켓 서비스
  final UserService userService; // 유저 서비스

  List<MessageData> messages = []; // 채팅 메시지 리스트

  int _currentPage = 0; // 현재 페이지 (메시지 데이터)
  final _pageSize = 50; // 메시지 데이터 페이지 사이즈

  ChatViewModel({
    required this.messageService,
    required this.roomService,
    required this.websocketService,
    required this.userService,
  });

  void setScrollController() {
    scrollController.addListener(() {
      // 스크롤 컨트롤러 설정
      print(
          '_scrollController.position.pixels: ${scrollController.position.pixels}, _scrollController.position.maxScrollExtent: ${scrollController.position.maxScrollExtent}');
      if (scrollController.position.pixels <=
          scrollController.position.maxScrollExtent - 30) {
        // 스크롤이 끝에서 -30에 도달하면
        print('messageDatas length : ${messages.length}, page : $_currentPage');
        if (messages.length >= (_currentPage + 1) * _pageSize &&
            messages.length < messageService.messageList.totalCount) {
          // 기준 데이터에 맞으면 업데이트
          _fetchItems();
        }
      }
    });
  }

  void addMessage(MessageData message) {
    messages.insert(0, message);
    notifyListeners();
  }

  RoomDetailData getRoomDetailData() {
    return roomService.roomDetail;
  }

  void exitRoom() {
    websocketService.exitRoom();
  }

  void unSubscribeToReceiveMessage() {
    websocketService.unSubscribeToRecieveMessage();
  }

  void reportUser(String roomId, String userId, String reportedUserId,
      String selectedReason, String reportReason) {
    userService.reportUser(
        roomId, userId, reportedUserId, selectedReason, reportReason);
  }

  // 메시지 데이터 추가 가져오기 (스크롤이 끝에 도달할 때) (API) [페이지네이션]
  Future<void> _fetchItems() async {
    print('fetchItems');
    try {
      final messages = await messageService.getMessageList(
        roomService.roomDetail.id.toString(),
        page: ++_currentPage,
        size: _pageSize,
      );

      this.messages = [...this.messages, ...messages];
      notifyListeners();
    } catch (e) {
      log('error: $e');
    }
  }

  Future<void> getMessages() async {
    messageService.messageList.items.clear();
    print('getMessages: ${roomService.roomDetail.id}');
    final messages = await messageService.getMessageList(
      roomService.roomDetail.id.toString(),
      page: _currentPage++,
      size: _pageSize * 2,
    );
    // this.messages = [...messages];
    notifyListeners();
  }

  void sendMessage(String message) {
    try {
      if (message.isNotEmpty) {
        websocketService.sendMessage(message);
        textController.clear();
      }
    } catch (e) {
      log('error: $e');
    }
  }

  void onMessageReceived(MessageData message) {
    print('onMessageReceived: ${message.content}');
    addMessage(message);
  }
}
