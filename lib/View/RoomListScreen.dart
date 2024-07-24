import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Roomlistscreen extends StatefulWidget {
  const Roomlistscreen({super.key});

  @override
  _RoomlistscreenState createState() => _RoomlistscreenState();
}

class _RoomlistscreenState extends State<Roomlistscreen> {
  List<RoomItem> roomItems = [
    const RoomItem('Room 1', '진문장은 이제 커플이다.', '2024-07-23T18:00:00'),
    const RoomItem('Room 2', '자라 보고 놀란 가슴... 더 놀란다..', '2024-07-11T13:00:00'),
    const RoomItem(
        'Room 3', '멕시칸은 고향으로 돌아가고 싶어한다. 하지만 돌아갈 수 없다.', '2024-07-21T07:00:00'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Continue'),
      ),
      body: Center(
        child: ListView.separated(
          itemCount: roomItems.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: roomItems[index],
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
    );
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

class _RoomItemState extends State<RoomItem> {
  String? date;
  String? time;
  String? year;
  String? month;
  String? day;

  @override
  Widget build(BuildContext context) {
    date = widget.latestSendAt.split('T')[0];
    time = widget.latestSendAt.split('T')[1];
    year = date!.split('-')[0];
    month = date!.split('-')[1];
    day = date!.split('-')[2];

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontSize: 20.0),
              ),
              const Spacer(),
              Text(
                '$year-$month-$day',
                style: const TextStyle(fontSize: 15.0),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                widget.latestMessage.length > 20
                    ? '${widget.latestMessage.substring(0, 20)}...'
                    : widget.latestMessage,
                style: const TextStyle(fontSize: 15.0),
              ),
              const Spacer(),
              Text(
                time!,
                style: const TextStyle(fontSize: 15.0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
