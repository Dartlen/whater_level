import 'dart:convert';
import 'dart:io';
import "dart:math";

import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
    );
  }
}

/// This is the stateless widget that the main application instantiates.
class MainState extends State<MainScreen> {
  TextEditingController _textController = TextEditingController();

  onItemChanged(String value) {
    setState(() {
      newDataList = namesPosts
          .where((item) => item.name.toLowerCase().contains(value.toLowerCase())
          || item.waterName.toLowerCase().contains(value.toLowerCase()) )
          .toList();
    });
  }

  final List<Color> colors = <Color>[
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange
  ];
  final data = ["one", "two", "three", "four", "five"];

  static List<Post> namesPosts = [
    Post(
        id: "0",
        name: "Полоцк",
        waterName: "Западная Двина",
        pointDayInfoChanges:
            PointDayInfoChanges(level: '285', temp: '8', delta: '-25')),
    Post(
        id: "1",
        name: "Витебск",
        waterName: "Западная Двина",
        pointDayInfoChanges:
            PointDayInfoChanges(level: '285', temp: '9', delta: '+25')),
    Post(
        id: "2",
        name: "Верхнедвинск",
        waterName: "Западная Двина",
        pointDayInfoChanges:
            PointDayInfoChanges(level: '285', temp: '10', delta: '-2')),
    Post(
        id: "3",
        name: "Сураж",
        waterName: "Западная Двина",
        pointDayInfoChanges:
            PointDayInfoChanges(level: '285', temp: '9', delta: '+1')),
    Post(
        id: "4",
        name: "Улла",
        waterName: "Западная Двина",
        pointDayInfoChanges:
            PointDayInfoChanges(level: '285', temp: '10', delta: '0'))
  ];

  List<Post> newDataList = List.from(namesPosts);
  //var zz = createPost();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Flutter ListView Example'),
        ),
        body: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Search Here...',
              ),
              onChanged: onItemChanged,
            ),
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: newDataList.length,
                  itemBuilder: (BuildContext context, int index) {
                    var post = newDataList[index];
                    return Row(
                      children: [
                        Expanded(
                            child: ListTile(
                          title: MessageItem(post.name, post.waterName)
                              .buildTitle(context),
                          subtitle: MessageItem(post.name, post.waterName)
                              .buildSubtitle(context),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PostScreen(name: post.name),
                              )),
                        )),
                        _getPointDayInfo(post.pointDayInfoChanges),
                      ],
                    );
                  }))
        ]));
  }
}

class MainScreen extends StatefulWidget {
  final String name;

  MainScreen({Key key, @required this.name}) : super(key: key);

  @override
  MainState createState() => MainState();
}

class PostScreen extends StatefulWidget {
  final String name;

  PostScreen({Key key, @required this.name}) : super(key: key);

  @override
  PostState createState() => PostState();
}

class PostState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Flutter ListView Example'),
        ),
        body: Center(
            child: FutureBuilder(
                future: loadPost(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return Container(
                        child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        var pointDay = snapshot.data[index];
                        return ListTile(
                            title: MessageItem(
                                    pointDay.date.toString(), pointDay.level)
                                .buildTitle(context));
                      },
                    ));
                  }
                })));
  }
}

T getRandomElement<T>(List<T> list) {
  final random = new Random();
  var i = random.nextInt(list.length);
  return list[i];
}

/// A ListItem that contains data to display a message.
class MessageItem implements ListItem {
  final String sender;
  final String body;

  MessageItem(this.sender, this.body);

  Widget buildTitle(BuildContext context) => Text(sender);

  Widget buildSubtitle(BuildContext context) => Text(body);
}

Widget myLayoutWidget() {
  return Align(
    alignment: Alignment(0.9, 0),
    child: Text("widget"),
  );
}

Widget _getPointDayInfo(PointDayInfoChanges pointDayInfoChanges) {
  Widget row;
  MaterialColor color;
  if (pointDayInfoChanges.delta.contains("+")) {
    color = Colors.green;
    row = rowTextWithPictureUpWater(pointDayInfoChanges.delta, color);
    //changeTextWidget = new TextSpan(text: pointDayInfoChanges.delta, style: new TextStyle(color: Colors.green));
  } else {
    color = Colors.red;
    row = rowTextWithPictureDownWater(pointDayInfoChanges.delta, color);
    //changeTextWidget = new TextSpan(text: pointDayInfoChanges.delta, style: new TextStyle(color: Colors.red));
  }

  return Expanded(
      child: Column(
    children: <Widget>[
      Align(
        alignment: Alignment(1, 0),
        child: Text(
          pointDayInfoChanges.level,
          style: TextStyle(color: Colors.indigo),
        ),
      ),
      row,
    ],
  ));
}

Widget rowTextWithPictureDownWater(String text, Color color) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: <Widget>[
      Text(text, style: TextStyle(color: color)),
      const Icon(
        AntIcons.caret_down_outline,
        color: Colors.red,
      ),
    ],
  );
}

Widget rowTextWithPictureUpWater(String text, Color color) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: <Widget>[
      Text(text, style: TextStyle(color: color)),
      const Icon(
        AntIcons.caret_up_outline,
        color: Colors.green,
      ),
    ],
  );
}

class PointDayInfoChanges {
  final String level;
  final String temp;
  final String delta;

  PointDayInfoChanges({this.level, this.temp, this.delta});
}

/// The base class for the different types of items the list can contain.
abstract class ListItem {
  /// The title line to show in a list item.
  Widget buildTitle(BuildContext context);

  /// The subtitle line, if any, to show in a list item.
  Widget buildSubtitle(BuildContext context);
}

class Item {
  int color;
  String field;

  Item(this.color, this.field);
}

Future<List<PointDay>> loadPost() async {
  var queryParameters = {'date': '15-03-2021'};
  final response = await http.get(
      Uri.https('rivers-whater-level.herokuapp.com', '/api/v1/resources/post',
          queryParameters),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      });

  if (response.statusCode == 200) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    Iterable l = json.decode(response.body);
    List<PointDay> posts =
        List<PointDay>.from(l.map((model) => PointDay.fromJson(model)));
    return posts;
    //return Post.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to load post');
  }
}

class Post {
  final String id;
  final String name;
  final String waterName;
  final PointDayInfoChanges pointDayInfoChanges;

  Post({this.id, this.name, this.waterName, this.pointDayInfoChanges});
}

class PointDay {
  final int id;
  final DateTime date;
  final String temp;
  final String level;
  final String delta;

  PointDay({this.id, this.date, this.temp, this.level, this.delta});

  factory PointDay.fromJson(json) {
    return PointDay(
        id: json[0],
        date: HttpDate.parse(json[1]),
        temp: json[2],
        level: json[5],
        delta: json[3]);
  }
}
