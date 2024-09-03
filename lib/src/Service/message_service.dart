import 'package:flutter/material.dart';
import 'package:ranchat_flutter/src/Model/MessageData.dart';
import 'package:ranchat_flutter/src/Model/MessageList.dart';
import 'package:ranchat_flutter/src/repository/message_repository.dart';

class MessageService with ChangeNotifier {
  /// 메시지 리스트
  MessageList messageList = MessageList(
    status: '',
    message: '',
    serverDateTime: '',
    items: [],
    page: 0,
    size: 0,
    totalCount: 0,
    totalPage: 0,
    empty: false,
  );

  final MessageRepository _messageRepository = MessageRepository();

  /// 메시지 리스트 조회
  Future<List<MessageData>> getMessageList(String roomId,
      {int page = 0, int size = 50}) async {
    List<MessageData> messages = await _messageRepository.getMessages(
        roomId: roomId, page: page, size: size);
    messageList = messageList.copyWith(items: messages);
    return messages;
  }

  /// 메시지 추가
  void addMessage(MessageData messageData) {
    messageList.items.insert(0, messageData);
    notifyListeners();
  }

  /// 메시지 초기화
  void clearMessageList() {
    messageList.items.clear();
    notifyListeners();
  }
}
