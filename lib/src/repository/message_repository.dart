import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:ranchat_flutter/src/Model/DefaultData.dart';
import 'package:ranchat_flutter/src/Model/MessageData.dart';
import 'package:ranchat_flutter/src/Model/MessageList.dart';
import 'package:ranchat_flutter/util/helper/network_helper.dart';

class MessageRepository {
  MessageRepository({
    Dio? dio,
  }) : dio = dio ?? Networkhelper.dio;

  final Dio dio;
  final String baseUrl = Defaultdata.domain;

  // 메시지 목록 조회
  Future<List<MessageData>> getMessages(
      {int page = 0, int size = 50, required String roomId}) async {
    print('getMessages: $roomId');
    try {
      final res = await dio.get(
          'https://${Defaultdata.domain}/v1/rooms/$roomId/messages?page=$page&size=$size');
      final messageList = MessageList.fromJson(res.data);

      return messageList.items;
    } catch (e, s) {
      log('Failed to get messages', error: e, stackTrace: s);
      return [];
    }

    // final response = await http.get(Uri.parse(
    //     'https://${Defaultdata.domain}/v1/rooms/$_roomId/messages?page=$page&size=$size'));
    // if (response.statusCode == 200) {
    //   final responseData = jsonDecode(utf8.decode(response.bodyBytes));
    //   messageList = MessageList.fromJson(responseData);
    //   return messageList.items;
    // } else {
    //   return [];
    // }
  }
}
