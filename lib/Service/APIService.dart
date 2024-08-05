import 'dart:convert';

import 'package:ranchat_flutter/Model/DefaultData.dart';
import 'package:ranchat_flutter/Model/MessageData.dart';
import 'package:ranchat_flutter/Model/MessageList.dart';
import 'package:ranchat_flutter/Model/RoomData.dart';
import 'package:http/http.dart' as http;
import 'package:ranchat_flutter/Model/RoomList.dart';
import 'package:ranchat_flutter/Service/ConnectingService.dart';

class ApiService {
  late String _userId;
  late String _roomId;

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

  ApiService(String userId, String roomId) {
    _userId = userId;
    _roomId = roomId;
  }

  void setRoomId(String roomId) {
    _roomId = roomId;
  }

  void setUserId(String userId) {
    _userId = userId;
  }

// 메시지 목록 조회
  Future<List<MessageData>> getMessages({int page = 0, int size = 20}) async {
    final response = await http.get(Uri.parse(
        'https://${Defaultdata.domain}/v1/rooms/$_roomId/messages?page=$page&size=$size'));
    if (response.statusCode == 200) {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      messageList = MessageList.fromJson(responseData);
      return messageList.items;
    } else {
      return [];
    }
  }

  // 방 목록 조회
  Future<List<RoomData>> getRooms({int page = 0, int size = 10}) async {
    final response = await http.get(Uri.parse(
        'https://${Defaultdata.domain}/v1/rooms?page=$page&size=$size&userId=$_userId'));
    print('response: ${response.body}');
    if (response.statusCode == 200) {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      final roomList = RoomList.fromJson(responseData);
      return roomList.items;
    } else {
      return [];
    }
  }

  // 회원 생성
  Future<void> createUser(String name) async {
    print('createUser : $_userId, $name');
    final response =
        await http.post(Uri.parse('https://${Defaultdata.domain}/v1/users'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              "id": _userId,
              "name": name,
            }));
    final responseData = jsonDecode(utf8.decode(response.bodyBytes));
    print('response: $responseData');
    if (response.statusCode == 200) {
      print('createUser : $response');
    } else {
      print('create user error');
    }
  }

  // 회원 이름 수정
  Future<void> updateUserName(String name) async {
    final response = await http.put(
      Uri.parse('https://${Defaultdata.domain}/v1/users/$_userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'name': name}),
    );
    final responseData = jsonDecode(utf8.decode(response.bodyBytes));
    print('response: $responseData');
    if (response.statusCode == 200) {
      print('updateUserName : $response');
    } else {
      print('update user name error : $response');
    }
  }
}
