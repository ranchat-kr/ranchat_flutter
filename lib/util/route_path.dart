import 'package:flutter/material.dart';
import 'package:ranchat_flutter/src/View/Chat/chat_view.dart';
import 'package:ranchat_flutter/src/View/RoomList/room_list_view.dart';
import 'package:ranchat_flutter/src/View/Setting/setting_view.dart';

abstract class RoutePath {
  static const String chat = 'chat';
  static const String roomList = 'roomList';
  static const String setting = 'setting';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    late final Widget page;
    switch (settings.name) {
      case RoutePath.chat:
        page = const ChatView();
        break;
      case RoutePath.roomList:
        page = const RoomListView();
        break;
      case setting:
        page = const SettingView();
        break;
    }

    return MaterialPageRoute(
      builder: (context) => page,
    );
  }
}
