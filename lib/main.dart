import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ranchat_flutter/src/Service/message_service.dart';
import 'package:ranchat_flutter/src/Service/room_service.dart';
import 'package:ranchat_flutter/src/Service/user_service.dart';
import 'package:ranchat_flutter/src/Service/websocket_service.dart';
import 'package:ranchat_flutter/src/View/Home/home_view.dart';

void main() {
  final UserService userService = UserService();
  final RoomService roomService = RoomService();
  final MessageService messageService = MessageService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => userService,
        ),
        ChangeNotifierProvider(
          create: (context) => roomService,
        ),
        ChangeNotifierProvider(
          create: (context) => messageService,
        ),
        ChangeNotifierProvider(
          create: (context) => WebsocketService(
            userService: userService,
            roomService: roomService,
            messageService: messageService,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ranchat',
      theme: ThemeData(
        fontFamily: 'DungGeunMo',
      ),
      themeMode: ThemeMode.system,
      home: const HomeView(),
    );
  }
}
