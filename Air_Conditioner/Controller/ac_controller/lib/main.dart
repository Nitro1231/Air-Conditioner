import 'package:flutter/material.dart';

enum mode { Auto, Dial, Bluetooth }

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Air Conditioner Controller',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyan,
        accentColor: Colors.cyan,
      ),
      home: MyHomePage(title: 'Air Conditioner Controller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

double outsideTemp = 0;
double insideTemp = 0;
double fanSpeed = 0;

class _MyHomePageState extends State<MyHomePage> {
  mode controlMode = mode.Auto;
  bool controlVisibility = false;

  void onControlModeChange(bool visibility, String field) {
    setState(() {
      if (field == "tag") {
        controlVisibility = visibility;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          //child: _widgetOptions.elementAt(_selectedIndex),
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ListView(
              shrinkWrap: true,
              children: <Widget>[
                ExpansionTile(
                  leading: Icon(Icons.timeline),
                  title: Text('Live Status'),
                  children: <Widget>[
                    Text(
                      '$outsideTemp',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    Text(
                      'Outside Temperature\n\n',
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      '$insideTemp',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    Text(
                      'Inside Temperature\n\n',
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.headline6,
                    )
                  ],
                ),
                ExpansionTile(
                  leading: Icon(Icons.phone_android),
                  title: Text('Mode'),
                  children: <Widget>[
                    ListTile(
                      title: const Text('Auto'),
                      leading: Radio(
                        value: mode.Auto,
                        groupValue: controlMode,
                        activeColor: Colors.cyan,
                        onChanged: (mode value) {
                          setState(() {
                            controlMode = value;
                            controlVisibility = false;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Dial'),
                      leading: Radio(
                        value: mode.Dial,
                        groupValue: controlMode,
                        activeColor: Colors.cyan,
                        onChanged: (mode value) {
                          setState(() {
                            controlMode = value;
                            controlVisibility = false;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Bluetooth'),
                      leading: Radio(
                        value: mode.Bluetooth,
                        groupValue: controlMode,
                        activeColor: Colors.cyan,
                        onChanged: (mode value) {
                          setState(() {
                            controlMode = value;
                            controlVisibility = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                AnimatedOpacity(
                    opacity: controlVisibility ? 1.0 : 0.4,
                    duration: Duration(milliseconds: 500),
                    child: AbsorbPointer(
                        absorbing: !controlVisibility,
                        child: ExpansionTile(
                          leading: Icon(Icons.computer),
                          title: Text('Control'),
                          children: <Widget>[
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.cyan[700],
                                inactiveTrackColor: Colors.black54,
                                trackShape: RectangularSliderTrackShape(),
                                trackHeight: 4.0,
                                thumbColor: Colors.cyan,
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 12.0),
                                overlayColor: Colors.cyan.withAlpha(32),
                                overlayShape: RoundSliderOverlayShape(
                                    overlayRadius: 28.0),
                              ),
                              child: Slider(
                                min: 0,
                                max: 255,
                                value: fanSpeed,
                                onChanged: (value) {
                                  setState(() {
                                    fanSpeed = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        )))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
