import 'package:flutter/material.dart';

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}

class BasicWheelListScreen extends StatefulWidget {
  @override
  _BasicWheelListScreenState createState() => _BasicWheelListScreenState();
}
class _BasicWheelListScreenState extends State<BasicWheelListScreen> {
  final FixedExtentScrollController _controller = FixedExtentScrollController();
  List<Widget> listtiles = [
    ListTile(
      leading: Icon(Icons.portrait),
      title: Text("Portrait"),
      subtitle: Text("Beautiful View..!"),
      trailing: Icon(Icons.arrow_forward_ios),
    ),
    ListTile(
      leading: Icon(Icons.landscape),
      title: Text("LandScape"),
      subtitle: Text("Beautiful View..!"),
      trailing: Icon(Icons.remove),
    ),
    ListTile(
      leading: Icon(Icons.map),
      title: Text("Map"),
      subtitle: Text("Map View..!"),
      trailing: Icon(Icons.wb_sunny),
    ),
    ListTile(
      leading: Icon(Icons.landscape),
      title: Text("LandScape"),
      subtitle: Text("Wonderful View..!"),
      trailing: Icon(Icons.wb_sunny),
    ),
    ListTile(
      leading: Icon(Icons.list),
      title: Text("List Example"),
      subtitle: Text("List Wheel Scroll view .!"),
      trailing: Icon(Icons.cloud),
    ),
    ListTile(
      leading: Icon(Icons.settings),
      title: Text("Settings"),
      subtitle: Text("Change the setting..!"),
      trailing: Icon(Icons.portrait),
    ),
    ListTile(
      leading: Icon(Icons.event),
      title: Text("Add data"),
      subtitle: Text("Data View..!"),
      trailing: Icon(Icons.add),
    ),
    ListTile(
      leading: Icon(Icons.landscape),
      title: Text("LandScape"),
      subtitle: Text("Beautiful View..!"),
      trailing: Icon(Icons.wb_sunny),
    ),
    ListTile(
      leading: Icon(Icons.email),
      title: Text("Email"),
      subtitle: Text("Check Email..!"),
      trailing: Icon(Icons.arrow_forward),
    ),
    ListTile(
      leading: Icon(Icons.games),
      title: Text("Games"),
      subtitle: Text("Play Games..!"),
      trailing: Icon(Icons.zoom_out_map),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("ListView ScrollView Wheel"),
        ),
        body: Center(
          child: ListWheelScrollView(
            controller: _controller,
            itemExtent: 80,
            magnification: 1.2,
            useMagnifier: true,
            physics: FixedExtentScrollPhysics(),
            children: listtiles, //List of widgets
          ),
        ));
  }
}