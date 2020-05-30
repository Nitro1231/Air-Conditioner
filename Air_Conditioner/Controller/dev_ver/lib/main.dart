// Flutter code sample for BottomNavigationBar

// This example shows a [BottomNavigationBar] as it is used within a [Scaffold]
// widget. The [BottomNavigationBar] has three [BottomNavigationBarItem]
// widgets and the [currentIndex] is set to index 0. The selected item is
// amber. The `_onItemTapped` function changes the selected item's index
// and displays a corresponding message in the center of the [Scaffold].
//
// ![A scaffold with a bottom navigation bar containing three bottom navigation
// bar items. The first one is selected.](https://flutter.github.io/assets-for-api-docs/assets/material/bottom_navigation_bar.png)

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Air Conditioner Controller',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyan,
        accentColor: Colors.cyan,
      ),
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;

  static bool controlVisibility = false;
  static bool bleConnected = false;
  static double outsideTemp = 0;
  static double insideTemp = 0;
  static double fanSpeed = 0;
  int index = 0;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const TextStyle h6 = TextStyle(fontSize: 40);
  static const TextStyle h3 =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const TextStyle h4 =
      TextStyle(fontSize: 25, fontWeight: FontWeight.bold);

  static List<Widget> _widgetOptions = <Widget>[
    Column(
      children: <Widget>[Text("Test")],
    ),
    Column(
      children: <Widget>[],
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int i) {
    setState(() {
      _selectedIndex = i;
      index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BottomNavigationBar Sample'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Visibility(
              visible: index == 0,
              child: Text('can you see me?'),
            ),
            Visibility(
              visible: index == 1,
              child: (AnimatedOpacity(
                opacity: bleConnected ? 1.0 : 0.4,
                duration: Duration(milliseconds: 500),
                child: AbsorbPointer(
                  absorbing: !bleConnected,
                  child: Scrollbar(
                    child: Column(
                      children: <Widget>[
                        GridView.count(
                          primary: false,
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          padding: const EdgeInsets.all(5),
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          children: <Widget>[
                            Column(children: <Widget>[
                              Text('\nOutside Temp\n', style: h3),
                              Text('$outsideTemp', style: h6)
                            ]),
                            Column(children: <Widget>[
                              Text('\nInside Temp\n', style: h3),
                              Text('$insideTemp', style: h6)
                            ]),
                            Column(
                              children: <Widget>[
                                Text('Fan Speed\n', style: h3),
                                SizedBox(
                                    height: 150.0,
                                    child: Stack(
                                      children: <Widget>[
                                        Center(
                                            child: Container(
                                                height: 150.0,
                                                width: 150.0,
                                                child:
                                                    CircularProgressIndicator(
                                                  value: 0.5,
                                                  backgroundColor:
                                                      Colors.black12,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.cyan),
                                                  strokeWidth: 7,
                                                ))),
                                        Center(child: Text('50%', style: h4))
                                      ],
                                    )),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Text('Dial\n', style: h3),
                                SizedBox(
                                    height: 150.0,
                                    child: Stack(
                                      children: <Widget>[
                                        Center(
                                            child: Container(
                                                height: 150.0,
                                                width: 150.0,
                                                child:
                                                    CircularProgressIndicator(
                                                  value: 0.5,
                                                  backgroundColor:
                                                      Colors.black12,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.cyan),
                                                  strokeWidth: 7,
                                                ))),
                                        Center(child: Text('50%', style: h4))
                                      ],
                                    ))
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth),
            title: Text('Connect'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            title: Text('Status'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Setting'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.cyan,
        backgroundColor: Colors.black45,
        onTap: _onItemTapped,
      ),
    );
  }
}
