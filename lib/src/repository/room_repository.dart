import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:ranchat_flutter/src/Model/DefaultData.dart';
import 'package:ranchat_flutter/src/Model/RoomData.dart';
import 'package:ranchat_flutter/src/Model/RoomDetailData.dart';
import 'package:ranchat_flutter/src/Model/RoomList.dart';
import 'package:ranchat_flutter/util/helper/network_helper.dart';

class RoomRepository {
  RoomRepository({
    Dio? dio,
  }) : dio = dio ?? Networkhelper.dio;

  final Dio dio;
  final String baseUrl = Defaultdata.domain;

  // 방 목록 조회
  Future<List<RoomData>> getRooms(
      {int page = 0, int size = 10, required String userId}) async {
    try {
      final res = await dio.get(
          'https://${Defaultdata.domain}/v1/rooms?page=$page&size=$size&userId=$userId');
      final roomList = RoomList.fromJson(res.data);
      return roomList.items;
    } catch (e, s) {
      log('Failed to get rooms', error: e, stackTrace: s);
      return [];
    }

    // final response = await http.get(Uri.parse(
    //     'https://${Defaultdata.domain}/v1/rooms?page=$page&size=$size&userId=$_userId'));
    // print('response: ${response.body}');
    // if (response.statusCode == 200) {
    //   final responseData = jsonDecode(utf8.decode(response.bodyBytes));
    //   final roomList = RoomList.fromJson(responseData);
    //   return roomList.items;
    // } else {
    //   return [];
    // }
  }

  // 채팅방 존재 여부 확인
  Future<bool> checkRoomExist(String userId) async {
    try {
      final res = await dio.get(
          'https://${Defaultdata.domain}/v1/rooms/exists-by-userId?userId=$userId');
      return res.data['data'];
    } catch (e, s) {
      log('Failed to check room exist', error: e, stackTrace: s);
      return false;
    }

    // final response = await http.get(Uri.parse(
    //     'https://${Defaultdata.domain}/v1/rooms/exists-by-userId?userId=$_userId'));
    // final responseData = jsonDecode(utf8.decode(response.bodyBytes));
    // print('checkRoomExist response: $responseData');
    // if (response.statusCode == 200) {
    //   return responseData['data'];
    // } else {
    //   return false;
    // }
  }

  // 채팅방 상세 조회
  Future<RoomDetailData> getRoomDetail(String userId, String roomId) async {
    try {
      final res = await dio
          .get('https://${Defaultdata.domain}/v1/rooms/$roomId?userId=$userId');
      final roomDetail = RoomDetailData.fromJson(res.data);
      return roomDetail;
    } catch (e, s) {
      log('Failed to get room detail', error: e, stackTrace: s);
      return RoomDetailData(
        id: 0,
        title: '',
        type: '',
        participants: [],
      );
    }

    // final response = await http.get(Uri.parse(
    //     'https://${Defaultdata.domain}/v1/rooms/$_roomId?userId=$_userId'));
    // if (response.statusCode == 200) {
    //   final responseData = jsonDecode(utf8.decode(response.bodyBytes));
    //   final roomDetail = RoomDetailData.fromJson(responseData);
    //   print('responseData: $responseData');
    //   return roomDetail;
    // } else {
    //   return RoomDetailData(
    //     id: 0,
    //     title: '',
    //     type: '',
    //     participants: [],
    //   );
    // }
  }

  // 방 생성
  Future<String> createRoom(String userId) async {
    print('createRoom userId: $userId');
    try {
      final res =
          await dio.post('https://${Defaultdata.domain}/v1/rooms', data: {
        "userIds": [userId],
        'roomType': 'GPT',
        'title': 'GPT 방',
      });
      return res.data['data'].toString();
    } catch (e, s) {
      log('Failed to create room', error: e, stackTrace: s);
    }
    return '';
  }
}
