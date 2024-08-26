import 'dart:developer';

import 'package:dio/dio.dart';

abstract class Networkhelper {
  static final Dio dio = Dio()
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 요청 시
          log('REQ : [${options.method}] ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 수신 시
          log('RES : [${response.statusCode}] ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (e, handler) {
          // 에러 시
          log('ERR : [${e.response?.statusCode}] ${e.requestOptions.path}');
          return handler.next(e);
        },
      ),
    );
}
