import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ranchat_flutter/ViewModel/ConnectingService.dart';

class RoomListScreen extends StatefulWidget {
  final Connectingservice connectingservice;
  const RoomListScreen({super.key, required this.connectingservice});

  @override
  _RoomListScreenState createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  final List<RoomItem> _roomItems = [];
  late Connectingservice _connectingservice;
  final ScrollController _scrollController = ScrollController();
  int _roomPage = 0;

  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _connectingservice = widget.connectingservice;
    getRooms();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        getRooms();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }

  void getRooms() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final rooms =
          await _connectingservice.getRooms(page: _roomPage++, size: 10);
      print('Rooms: $rooms');
      setState(() {
        for (var room in rooms) {
          _roomItems.add(
              RoomItem(room.title, room.latestMessage, room.latestMessageAt));
        }
        _isLoading = false;
      });
    } catch (e) {
      print('getRooms error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  return InkWell(
                    onTap: () {
                      print('Room ${index + 1} is clicked');
                    },
                    highlightColor: Colors.grey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _roomItems[index],
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
        ));
  }
}

class RoomItem extends StatefulWidget {
  const RoomItem(this.title, this.latestMessage, this.latestSendAt,
      {super.key});
  final String title;
  final String latestMessage;
  final String latestSendAt;

  @override
  _RoomItemState createState() => _RoomItemState();
}

enum TimeFormatState {
  today,
  yesterday,
  thisYear,
  anotherYear,
  none,
}

class _RoomItemState extends State<RoomItem> {
  // format : 2024-07-23T23:00:00
  String date = '';
  String year = '';
  String month = '';
  String day = '';
  String time = '';
  String hour = '';
  String minute = '';
  String second = '';
  String nowDate = DateTime.now().toString().split('.')[0].split(' ')[0];
  String nowYear = '';
  String nowMonth = '';
  String nowDay = '';
  String nowTime = DateTime.now().toString().split('.')[0].split(' ')[1];
  String nowHour = '';
  String nowMinute = '';
  String nowSecond = '';

  String timeFormat = '';
  TimeFormatState _timeFormatState = TimeFormatState.none;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.latestSendAt.isNotEmpty) {
      date = widget.latestSendAt.split('T')[0]; // 2024-07-23
      time = widget.latestSendAt.split('T')[1]; // 23:00:00
      year = date.split('-')[0]; // 2024
      month = date.split('-')[1]; // 07
      day = date.split('-')[2]; // 23
      hour = time.split(':')[0]; // 23
      minute = time.split(':')[1]; // 00
      second = time.split(':')[2]; // 00

      nowYear = nowDate.split('-')[0];
      nowMonth = nowDate.split('-')[1];
      nowDay = nowDate.split('-')[2];
      nowHour = nowTime.split(':')[0];
      nowMinute = nowTime.split(':')[1];
      nowSecond = nowTime.split(':')[2];

      final now = int.parse(nowYear) * 365 +
          int.parse(nowMonth) * 30 +
          int.parse(nowDay);
      final data =
          int.parse(year) * 365 + int.parse(month) * 30 + int.parse(day);

      if (year == nowYear && month == nowMonth && day == nowDay) {
        if (int.parse(hour) >= 0 && int.parse(hour) < 12) {
          timeFormat = '오전 $hour:$minute';
        } else {
          timeFormat = '오후 ${int.parse(hour) - 12}:$minute';
        }
        _timeFormatState = TimeFormatState.today;
      } else if (now - data == 1) {
        timeFormat = '어제';
        _timeFormatState = TimeFormatState.yesterday;
      } else if (year == nowYear) {
        timeFormat = '$month월 $day일';
        _timeFormatState = TimeFormatState.thisYear;
      } else {
        timeFormat =
            '$year. ${month.length == 1 ? '0$month' : month}. ${day.length == 1 ? '0$day' : day}.';
        _timeFormatState = TimeFormatState.anotherYear;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontSize: 20.0, color: Colors.pink),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  timeFormat,
                  style: TextStyle(
                      fontSize: _timeFormatState == TimeFormatState.today ||
                              _timeFormatState == TimeFormatState.thisYear
                          ? 13.0
                          : _timeFormatState == TimeFormatState.yesterday
                              ? 15.0
                              : _timeFormatState == TimeFormatState.anotherYear
                                  ? 12.5
                                  : 0.0,
                      color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.latestMessage,
              style: const TextStyle(fontSize: 12.0, color: Colors.white),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}
