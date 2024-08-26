import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ranchat_flutter/src/View/RoomList/room_list_view_model.dart';
import 'package:ranchat_flutter/src/View/RoomList/widget/RoomItem.dart';
import 'package:ranchat_flutter/src/View/base_view.dart';

class RoomListView extends StatefulWidget {
  const RoomListView({
    super.key,
  });

  @override
  _RoomListViewState createState() => _RoomListViewState();
}

class _RoomListViewState extends State<RoomListView> {
  final List<RoomItem> _roomItems = [];

  final ScrollController _scrollController = ScrollController();
  final int _roomPage = 0;

  final bool _isLoading = false;

  late RoomListViewModel roomListViewModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    roomListViewModel = RoomListViewModel(
      roomService: context.read(),
      userService: context.read(),
      webSocketService: context.read(),
    );
    roomListViewModel.getRoomList();
    // getRooms();
    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels ==
    //       _scrollController.position.maxScrollExtent) {
    //     getRooms();
    //   }
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }

  // void getRooms() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     final rooms = await _connectingservice.apiService
  //         ?.getRooms(page: _roomPage++, size: 10);
  //         await
  //     print('Rooms: $rooms');
  //     setState(() {
  //       for (var room in rooms!) {
  //         _roomItems.add(RoomItem(room));
  //       }
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     print('getRooms error: $e');
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  // void _enterRoom(int index) {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     _connectingservice.setRoomId(_roomItems[index].room.id.toString());
  //     _connectingservice.websocketService
  //         ?.setRoomId(_roomItems[index].room.id.toString());
  //     _connectingservice.apiService
  //         ?.setRoomId(_roomItems[index].room.id.toString());
  //     _connectingservice.websocketService?.enterRoom();
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => ChatView(
  //           connectingservice: _connectingservice,
  //         ),
  //       ),
  //     ).then((_) {
  //       setState(() {
  //         _roomItems.clear();
  //         _roomPage = 0;
  //         getRooms();
  //       });
  //     });
  //   } catch (e) {
  //     print('enterRoom error: $e');
  //   }
  //   setState(() {
  //     _isLoading = false;
  //   });
  //}

  // void exitRoom(String roomId) {
  //   setState(() {
  //     _isLoading = true;
  //     _connectingservice.apiService?.exitSelectedRoom(roomId);
  //     _isLoading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      viewModel: RoomListViewModel(
        roomService: context.read(),
        userService: context.read(),
        webSocketService: context.read(),
      ),
      builder: (context, viewModel) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              highlightColor: Colors.grey,
            ),
            title: const Text(
              'Continue',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            actions: const <Widget>[],
          ),
          body: Stack(
            children: [
              Center(
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: _roomItems.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(_roomItems[index].room.id.toString()),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('방 나가기'),
                              content: const Text('이 방에서 나가시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: const Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      viewModel.exitRoom();
                                      // exitRoom(
                                      //     _roomItems[index].room.id.toString());
                                      _roomItems.removeAt(index);
                                    });
                                    Navigator.pop(context, true);
                                  },
                                  child: const Text('나가기'),
                                )
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        setState(() {
                          _roomItems.removeAt(index);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('방에서 나갔습니다.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: Text(
                            '나가기',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          viewModel.enterRoom(index);
                        },
                        highlightColor: Colors.grey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _roomItems[index],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: Colors.grey,
                    );
                  },
                ),
              ),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          )),
    );
  }
}
