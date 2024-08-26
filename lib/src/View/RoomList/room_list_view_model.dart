import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ranchat_flutter/src/Service/room_service.dart';
import 'package:ranchat_flutter/src/Service/user_service.dart';
import 'package:ranchat_flutter/src/Service/websocket_service.dart';
import 'package:ranchat_flutter/src/View/RoomList/room_list_view.dart';
import 'package:ranchat_flutter/src/View/RoomList/widget/RoomItem.dart';
import 'package:ranchat_flutter/src/View/base_view_model.dart';
import 'package:ranchat_flutter/util/route_path.dart';

class RoomListViewModel extends BaseViewModel {
  final List<RoomItem> roomItems = [];

  final RoomService roomService;
  final UserService userService;
  final WebsocketService webSocketService;

  final ScrollController scrollController = ScrollController();
  int roomPage = 0;

  RoomListViewModel(
      {required this.roomService,
      required this.userService,
      required this.webSocketService}) {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        getRoomList();
      }
    });
  }

  void getRoomList() {
    roomService.getRoomList(roomPage, 10, userService.userId);
    for (var room in roomService.roomList) {
      roomItems.add(RoomItem(room));
    }
  }

  void enterRoom(int index) {
    final room = roomItems[index].room;

    webSocketService.enterRoom();

    roomService
        .getRoomDetail(userService.userId, room.id.toString())
        .then((value) {
      RoutePath.onGenerateRoute(const RouteSettings(name: RoutePath.chat));
    });
  }

  void exitRoom() {
    webSocketService.exitRoom();
  }
}
