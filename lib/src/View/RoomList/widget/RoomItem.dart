import 'package:flutter/material.dart';
import 'package:ranchat_flutter/src/Model/RoomData.dart';

class RoomItem extends StatefulWidget {
  RoomItem(this.room, {super.key});
  RoomData room;

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

    if (widget.room.latestMessageAt.isNotEmpty) {
      date = widget.room.latestMessageAt.split('T')[0]; // 2024-07-23
      time = widget.room.latestMessageAt.split('T')[1]; // 23:00:00
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
              Expanded(
                child: Text(
                  widget.room.title,
                  style: const TextStyle(fontSize: 20.0, color: Colors.pink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
              widget.room.latestMessage,
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
