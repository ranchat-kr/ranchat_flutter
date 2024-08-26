import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:ranchat_flutter/src/Model/DefaultData.dart';
import 'package:ranchat_flutter/util/helper/network_helper.dart';

class ReportRepository {
  ReportRepository({
    Dio? dio,
  }) : dio = dio ?? Networkhelper.dio;

  final Dio dio;
  final String baseUrl = Defaultdata.domain;

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
