import 'package:ran_talk/Model/User.dart';
import 'package:ran_talk/Service/APIService.dart';
import 'package:ran_talk/Service/WebsocketService.dart';

import '../Model/MessageData.dart';

class Connectingservice {
  String _roomId = "1";
  final String userId1 = "0190964c-af3f-7486-8ac3-d3ff10cc1470";
  final String userId2 = "0190964c-ee3a-7e81-a1f8-231b5d97c2a1";
  late String _userId = '';
  User? user;

  WebsocketService? websocketService;
  ApiService? apiService;

  Connectingservice(
      {Function(MessageData)? onMessageReceivedCallback,
      Function(dynamic response)? onMatchingSuccess}) {
    websocketService = WebsocketService(
        userId: _userId,
        roomId: _roomId,
        onMessageReceivedCallback: onMessageReceivedCallback,
        onMatchingSuccess: onMatchingSuccess);
    apiService = ApiService(_userId, _roomId);
  }

  String get userId => _userId;
  set userId(String userId) {
    _userId = userId;
    websocketService?.setUserId(userId);
    apiService?.setUserId(userId);
  }

  // void setOnMessageReceivedCallback(Function(MessageData) callback) async {
  //   _onMessageReceivedCallback = callback;
  // }

  void setRoomId(String roomId) async {
    print('set room id: $roomId');
    _roomId = roomId;
  }

  void setUserId(String userId) {
    _userId = userId;
    websocketService?.setUserId(userId);
    apiService?.setUserId(userId);
  }

  // #region WebSocket
  // #region first setting
  //WebSocket server
  // void connectToWebSocket() async {
  //   try {
  //     _stompClient = StompClient(
  //       config: StompConfig(
  //         url: 'ws://$_domain/endpoint',
  //         stompConnectHeaders: {'userId': userId},
  //         onConnect: (StompFrame frame) => subscribeToMatchingSuceess(frame),
  //         onWebSocketError: (dynamic error) => print(error.toString()),
  //         onWebSocketDone: () => print('WebSocket connect done.'),
  //         onStompError: (StompFrame frame) =>
  //             print('Stomp error: ${frame.body}'),
  //         onDisconnect: (StompFrame frame) =>
  //             print('Disconnected: ${frame.body}'),
  //         onDebugMessage: (String message) => print('Debug: $message'),
  //       ),
  //     );
  //     _stompClient?.activate();
  //   } catch (e) {
  //     print('error: $e');
  //   }
  // }

  // // 웹소켓 매칭 성공 구독
  // void subscribeToMatchingSuceess(StompFrame frame) async {
  //   print('subscribe to matching success');
  //   _stompClient?.subscribe(
  //     destination: '/user/$userId/queue/v1/matching/success',
  //     callback: onMatchingSuccess,
  //   );
  // }

  // // 웹소켓 메시지 받기 구독
  // void subscribeToRecieveMessage() async {
  //   _stompClient?.subscribe(
  //     destination: '/topic/v1/rooms/$_roomId/messages/new',
  //     callback: onMessageReceived,
  //   );
  // }
  // // #endregion

  // // #region recieve
  // // 메시지 수신
  // void onMessageReceived(StompFrame frame) async {
  //   print('Received: ${frame.body}');
  //   if (_onMessageReceivedCallback != null) {
  //     final message = Message.fromJson(jsonDecode(frame.body ?? ''));

  //     _onMessageReceivedCallback!(message.messageData);
  //   }
  // }

  // // 매칭 성공
  // void onMatchingSuccess(StompFrame frame) async {
  //   print('Matching Success: ${frame.body}');
  //   if (_onMatchingSuccessCallback != null) {
  //     final matchingSuccess = jsonDecode(frame.body ?? '');
  //     _onMatchingSuccessCallback!(matchingSuccess);
  //   }
  // }
  // // #endregion

  // // #region send
  // // 메시지 전송
  // void sendMessage(String content) async {
  //   print('send message');
  //   if (_stompClient!.connected) {
  //     try {
  //       _stompClient?.send(
  //           destination: '/v1/rooms/$_roomId/messages/send',
  //           body: jsonEncode({
  //             "userId": userId,
  //             "content": content,
  //             "contentType": "TEXT",
  //           }));
  //     } catch (e) {
  //       print('send Message error: $e');
  //     }
  //   } else {
  //     print('send message error: not connected');
  //   }
  // }

  // // 방 입장
  // void enterRoom() async {
  //   print('enter room');
  //   if (_stompClient!.connected) {
  //     try {
  //       _stompClient?.send(
  //         destination: '/v1/rooms/$_roomId/enter',
  //         body: jsonEncode({
  //           "userId": userId,
  //         }),
  //       );
  //       subscribeToRecieveMessage();
  //     } catch (e) {
  //       print('enter room error: $e');
  //     }
  //   } else {
  //     print('enter room error: not connected');
  //   }
  // }

  // // 매칭 요청
  // void requestMatching() async {
  //   if (_stompClient!.connected) {
  //     try {
  //       _stompClient?.send(
  //         destination: '/v1/matching/apply',
  //         body: jsonEncode({"userId": userId}),
  //       );
  //     } catch (e) {
  //       print('request matching error: $e');
  //     }
  //   } else {
  //     print('request matching error: not connected');
  //   }
  // }

  // // 임시로 쓰는 매칭 함수
  // void tempRequestMatching() async {
  //   if (_stompClient!.connected) {
  //     try {
  //       _stompClient?.send(
  //         destination: '/v1/matching/apply',
  //         body: jsonEncode({"userId": userId2}),
  //       );
  //     } catch (e) {
  //       print('request matching error: $e');
  //     }
  //   } else {
  //     print('request matching error: not connected');
  //   }
  // }

  // // 매칭 취소
  // void cancelMatching() async {
  //   print('cancel matching');
  //   if (_stompClient!.connected) {
  //     try {
  //       _stompClient?.send(
  //         destination: '/v1/matching/cancel',
  //         body: jsonEncode({"userId": userId}),
  //       );
  //     } catch (e) {
  //       print('cancel matching error: $e');
  //     }
  //   } else {
  //     print('cancel matching error: not connected');
  //   }
  // }
  // // #endregion
  // // #endregion

  // void changeUser() {
  //   userId = userId == userId1 ? userId2 : userId1;
  // }

  // void dispose() {
  //   _stompClient?.deactivate();
  // }

  // #region HTTP
  // 메시지 목록 조회
  // Future<List<MessageData>> getMessages({int page = 0, int size = 20}) async {
  //   final response = await http.get(Uri.parse(
  //       'https://$_domain/v1/rooms/$_roomId/messages?page=$page&size=$size'));
  //   if (response.statusCode == 200) {
  //     final responseData = jsonDecode(utf8.decode(response.bodyBytes));
  //     messageList = MessageList.fromJson(responseData);
  //     return messageList.items;
  //   } else {
  //     return [];
  //   }
  // }

  // // 방 목록 조회
  // Future<List<RoomData>> getRooms({int page = 0, int size = 10}) async {
  //   final response = await http.get(Uri.parse(
  //       'https://$_domain/v1/rooms?page=$page&size=$size&userId=$userId'));
  //   print('response: ${response.body}');
  //   if (response.statusCode == 200) {
  //     final responseData = jsonDecode(utf8.decode(response.bodyBytes));
  //     final roomList = RoomList.fromJson(responseData);
  //     return roomList.items;
  //   } else {
  //     return [];
  //   }
  // }

  // // 회원 생성
  // Future<void> createUser() async {
  //   final response = await http.post(Uri.parse('https://$_domain/v1/users'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode({
  //         "userId": userId,
  //         "name": "SIUSIUSIU",
  //       }));
  //   if (response.statusCode == 200) {
  //     print('createUser : $response');
  //   } else {
  //     print('create user error');
  //   }
  // }

  // // 회원 이름 수정
  // Future<void> updateUserName(String name) async {
  //   final response = await http.put(
  //     Uri.parse('https://$_domain/v1/users/$userId'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode({'name': name}),
  //   );
  //   final responseData = jsonDecode(utf8.decode(response.bodyBytes));
  //   print('response: $responseData');
  //   if (response.statusCode == 200) {
  //     print('updateUserName : $response');
  //   } else {
  //     print('update user name error : $response');
  //   }
  // }
  // // #endregion
}
