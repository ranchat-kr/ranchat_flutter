import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ranchat_flutter/Model/DefaultData.dart';
import 'package:ranchat_flutter/Model/MessageData.dart';
import 'package:ranchat_flutter/Model/MessageList.dart';
import 'package:ranchat_flutter/Model/RoomData.dart';
import 'package:ranchat_flutter/Model/RoomDetailData.dart';
import 'package:ranchat_flutter/Model/RoomList.dart';
import 'package:ranchat_flutter/Model/User.dart';

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

  // 신고 하기
  Future<void> reportUser(
      String reportedUserId, String selectedReason, String reportReason) async {
    String reportType = '';

    switch (selectedReason) {
      case '스팸':
        reportType = 'SPAM';
        break;
      case '욕설 및 비방':
        reportType = 'HARASSMENT';
        break;
      case '광고':
        reportType = 'ADVERTISEMENT';
        break;
      case '허위 정보':
        reportType = 'MISINFORMATION';
        break;
      case '저작권 침해':
        reportType = 'COPYRIGHT_INFRINGEMENT';
        break;
      case '기타':
        reportType = 'ETC';
        break;
    }
    print(
        'reportUser | roomId: $_roomId, reporterId: $_userId, reportedUserId: $reportedUserId, reportType: $reportType, reportReason: $reportReason');

    try {
      final response = await http.post(
        Uri.parse('https://${Defaultdata.domain}/v1/reports'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "roomId": _roomId,
          "reporterId": _userId,
          "reportedUserId": reportedUserId,
          "reportType": reportType,
          "reportReason": reportReason,
        }),
      );
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      print('response: $responseData');
      if (response.statusCode == 200) {
        print('reportUser : $response');
      } else {
        throw Exception('<reportUser> Failed to load data');
      }
    } catch (e) {
      throw Exception('<reportUser> API 통신 실패: $e');
    }
  }

// 메시지 목록 조회
  Future<List<MessageData>> getMessages({int page = 0, int size = 20}) async {
    try {
      final response = await http.get(Uri.parse(
          'https://${Defaultdata.domain}/v1/rooms/$_roomId/messages?page=$page&size=$size'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        messageList = MessageList.fromJson(responseData);
        return messageList.items;
      } else {
        throw Exception('<getMessages> Failed to load data');
      }
    } catch (e) {
      throw Exception('<getMessages> API 통신 실패: $e');
    }
  }

  // 방 생성
  Future<String> createRoom() async {
    print('createRoom : $_userId');
    try {
      final response = await http.post(
        Uri.parse('https://${Defaultdata.domain}/v1/rooms'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          {
            "userIds": [_userId],
            'roomType': 'GPT', // 임시로 GPT로 설정
            'title': 'test Room',
          },
        ),
      );
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      print('createRoom response: $responseData');
      if (response.statusCode == 200) {
        final roomId = responseData['data'];
        return roomId.toString();
      } else {
        throw Exception('<createRoom> Failed to load data');
      }
    } catch (e) {
      throw Exception('<createRoom> API 통신 실패: $e');
    }
  }

  // 채팅방 상세 조회
  Future<RoomDetailData> getRoomDetail() async {
    try {
      final response = await http.get(Uri.parse(
          'https://${Defaultdata.domain}/v1/rooms/$_roomId?userId=$_userId'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        final roomDetail = RoomDetailData.fromJson(responseData);
        print('responseData: $responseData');
        return roomDetail;
      } else {
        throw Exception('<getRoomDetail> Failed to load data');
      }
    } catch (e) {
      throw Exception('<getRoomDetail> API 통신 실패: $e');
    }
  }

  // 방 목록 조회
  Future<List<RoomData>> getRooms({int page = 0, int size = 10}) async {
    try {
      final response = await http.get(Uri.parse(
          'https://${Defaultdata.domain}/v1/rooms?page=$page&size=$size&userId=$_userId'));
      print('response: ${response.body}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        final roomList = RoomList.fromJson(responseData);
        return roomList.items;
      } else {
        throw Exception('<getRooms> Failed to laod data');
      }
    } catch (e) {
      throw Exception('<getRooms> API 통신 실패: $e');
    }
  }

  // 채팅방 존재 여부 확인
  Future<bool> checkRoomExist() async {
    try {
      final response = await http.get(Uri.parse(
          'https://${Defaultdata.domain}/v1/rooms/exists-by-userId?userId=$_userId'));
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      print('checkRoomExist response: $responseData');
      if (response.statusCode == 200) {
        return responseData['data'];
      } else {
        throw Exception('<checkRoomExist> Failed to load data');
      }
    } catch (e) {
      throw Exception('<checkRoomExist> API 통신 실패: $e');
    }
  }

  // 현재 채팅방 퇴장
  Future<void> exitRoom() async {
    try {
      final response = await http.post(
        Uri.parse('https://${Defaultdata.domain}/v1/rooms/$_roomId/exit'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          {
            "userId": _userId,
          },
        ),
      );
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      print('response: $responseData');
      if (response.statusCode == 200) {
        _roomId = '';
        print('leaveRoom : $response');
      } else {
        throw Exception('<exitRoom> Failed to load data');
      }
    } catch (e) {
      throw Exception('<exitRoom> API 통신 실패: $e');
    }
  }

  // 특정 채팅방 퇴장
  Future<void> exitSelectedRoom(String roomId) async {
    try {
      final response = await http.post(
        Uri.parse('https://${Defaultdata.domain}/v1/rooms/$roomId/exit'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          {
            "userId": _userId,
          },
        ),
      );
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      print('response: $responseData');
      if (response.statusCode == 200) {
        print('leaveRoom : $response');
      } else {
        throw Exception('<exitSelectedRoom> Failed to load data');
      }
    } catch (e) {
      throw Exception('<exitSelectedRoom> API 통신 실패: $e');
    }
  }

  // 회원 생성
  Future<void> createUser(String name) async {
    try {
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
        throw Exception('<createUser> Failed to load data');
      }
    } catch (e) {
      throw Exception('<createUser> API 통신 실패: $e');
    }
  }

  // 회원 조회
  Future<User> getUser() async {
    try {
      final response = await http.get(
        Uri.parse('https://${Defaultdata.domain}/v1/users/$_userId'),
      );
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      print('response: $responseData');
      if (response.statusCode == 200) {
        return User.fromJson(responseData['data']);
      } else {
        throw Exception('<getUser> Failed to load data');
      }
    } catch (e) {
      throw Exception('<getUser> API 통신 실패: $e');
    }
  }

  // 회원 이름 수정
  Future<void> updateUserName(String name) async {
    try {
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
        throw Exception('<updateUserName> Failed to load data');
      }
    } catch (e) {
      throw Exception('<updateUserName> API 통신 실패: $e');
    }
  }
}
