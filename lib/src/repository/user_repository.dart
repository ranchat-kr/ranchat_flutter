import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:ranchat_flutter/src/Model/DefaultData.dart';
import 'package:ranchat_flutter/src/Model/User.dart';
import 'package:ranchat_flutter/util/helper/network_helper.dart';

class UserRepository {
  UserRepository({
    Dio? dio,
  }) : dio = dio ?? Networkhelper.dio;

  final Dio dio;
  final String baseUrl = Defaultdata.domain;

  // 회원 생성
  Future<User> createUser(String userId, String name) async {
    try {
      final res = await dio.post(
        'https://${Defaultdata.domain}/v1/users',
        data: {
          "id": userId,
          "name": name,
        },
      );
      return User.fromJson(res.data);
    } catch (e, s) {
      log('Failed to create user', error: e, stackTrace: s);
      return User(id: '', name: '');
    }

    // print('createUser : $_userId, $name');
    // final response =
    //     await http.post(Uri.parse('https://${Defaultdata.domain}/v1/users'),
    //         headers: <String, String>{
    //           'Content-Type': 'application/json; charset=UTF-8',
    //         },
    //         body: jsonEncode({
    //           "id": _userId,
    //           "name": name,
    //         }));
    // final responseData = jsonDecode(utf8.decode(response.bodyBytes));
    // print('response: $responseData');
    // if (response.statusCode == 200) {
    //   print('createUser : $response');
    // } else {
    //   print('create user error');
    // }
  }

  // 회원 조회
  Future<User> getUser(String userId) async {
    try {
      final res =
          await dio.get('https://${Defaultdata.domain}/v1/users/$userId');
      return User.fromJson(res.data);
    } catch (e, s) {
      log('Failed to get user', error: e, stackTrace: s);
      return User(id: '', name: '');
    }
  }

  // 회원 이름 수정
  Future<void> updateUserName(String userId, String name) async {
    try {
      final res = await dio.put(
        'https://${Defaultdata.domain}/v1/users/$userId',
        data: {
          "name": name,
        },
      );
    } catch (e, s) {
      log('Failed to update user name', error: e, stackTrace: s);
    }

    // final response = await http.put(
    //   Uri.parse('https://${Defaultdata.domain}/v1/users/$_userId'),
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //   },
    //   body: jsonEncode({'name': name}),
    // );
    // final responseData = jsonDecode(utf8.decode(response.bodyBytes));
    // print('response: $responseData');
    // if (response.statusCode == 200) {
    //   print('updateUserName : $response');
    // } else {
    //   print('update user name error : $response');
    // }
  }

  // 신고 하기
  Future<void> reportUser(String roomId, String userId, String reportedUserId,
      String selectedReason, String reportReason) async {
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

    try {
      final res = await dio.post(
        'https://${Defaultdata.domain}/v1/reports',
        data: {
          "roomId": roomId,
          "reporterId": userId,
          "reportedUserId": reportedUserId,
          "reportType": reportType,
          "reportReason": reportReason,
        },
      );
    } catch (e, s) {
      log('Failed to report user', error: e, stackTrace: s);
    }

    // final response = await http.post(
    //   Uri.parse('https://${Defaultdata.domain}/v1/reports'),
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //   },
    //   body: jsonEncode({
    //     "roomId": _roomId,
    //     "reporterId": _userId,
    //     "reportedUserId": reportedUserId,
    //     "reportType": reportType,
    //     "reportReason": reportReason,
    //   }),
    // );
    // final responseData = jsonDecode(utf8.decode(response.bodyBytes));
    // print('response: $responseData');
    // if (response.statusCode == 200) {
    //   print('reportUser : $response');
    // } else {
    //   print('report user error : $response');
    // }
  }
}
