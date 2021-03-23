import 'dart:convert';
import 'dart:io';
import "dart:math";

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
class MainScreen extends StatelessWidget {
  final List<Color> colors = <Color>[
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange
  ];
  final data = ["one", "two", "three", "four", "five"];

  final List<Post> namesPosts = [
    Post(id: "0", name: "Полоцк", waterName: "Западная Двина"),
    Post(id: "1", name: "Витебск", waterName: "Западная Двина"),
    Post(id: "2", name: "Верхнедвинск", waterName: "Западная Двина"),
    Post(id: "3", name: "Сураж", waterName: "Западная Двина"),
    Post(id: "3", name: "Улла", waterName: "Западная Двина")
  ];

  //var zz = createPost();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter ListView Example'),
      ),
      body: Center(
          child: ListView.builder(
              itemCount: namesPosts.length,
              itemBuilder: (BuildContext context, int index) {
                var post = namesPosts[index];
                return ListTile(
                    title: MessageItem(post.name, post.waterName)
                        .buildTitle(context),
                    subtitle: MessageItem(post.name, post.waterName)
                        .buildSubtitle(context),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Main(name: post.name),
                      )),);
              })),
    );
  }
}

class Main extends StatefulWidget {
  final String name;

  Main({Key key, @required this.name}) : super(key: key);

  @override
  PostScreen createState() => PostScreen();
}

class PostScreen extends State<Main> {

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
                                  title: MessageItem(pointDay.date.toString(), pointDay.level).buildTitle(context));
                            },
                        ));
                        // child: ListView.builder(
                        //     itemCount: snapshot.data.length,
                        //     scrollDirection: Axis.horizontal,
                        //     itemBuilder: (BuildContext context, int index) {
                        //       return Text('${snapshot.data[index]}');
                        //     }));
                  }
                })
        ));

    // child: ListView.builder(
    //     itemCount: pointDays.length,
    //     itemBuilder: (BuildContext context, int index) {
    //       var post = pointDays[index];
    //       return ListTile(
    //           title: MessageItem(post.name, post.waterName)
    //               .buildTitle(context),
    //           subtitle: MessageItem(post.name, post.waterName)
    //               .buildSubtitle(context));
    //     })),
    // );
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

  Post({this.id, this.name, this.waterName});
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

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
