import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:permission_handler/permission_handler.dart';

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
  BleManager bleManager = BleManager(); //BLE Manager
  bool _isScanning= false;
  List<BleDeviceItem> deviceList = [];

  mode controlMode = mode.Auto;
  bool controlVisibility = false;
  bool bleConnected = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    await bleManager.createClient(
        restoreStateIdentifier: "example-restore-state-identifier",
        restoreStateAction: (peripherals) {
          peripherals?.forEach((peripheral) {
            print("Restored peripheral: ${peripheral.name}");
          });
        })
        .catchError((e) => print("Couldn't create BLE client  $e"))
        .then((_) => checkPermissions()) // checking permission
        .catchError((e) => print("Permission check error $e"));
    //.then((_) => _waitForBluetoothPoweredOn())
  }

  checkPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.contacts.request().isGranted) {
      }
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location
      ].request();
      print(statuses[Permission.location]);
    }
  }


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
        body: AnimatedOpacity(
            opacity: bleConnected ? 1.0 : 0.4,
            duration: Duration(milliseconds: 500),
            child: AbsorbPointer(
              absorbing: !bleConnected,
              child: Scrollbar(
                //mainAxisAlignment: MainAxisAlignment.start,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    ExpansionTile(
                        leading: Icon(Icons.timeline),
                        title: Text('Live Status'),
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
                                Text(
                                  'Outside Temp\n',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                Text(
                                  '$outsideTemp',
                                  style: Theme.of(context).textTheme.headline3,
                                )
                              ]),
                              Column(children: <Widget>[
                                Text(
                                  'Inside Temp\n',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                Text(
                                  '$insideTemp',
                                  style: Theme.of(context).textTheme.headline3,
                                )
                              ]),
                              Column(
                                children: <Widget>[
                                  Text(
                                    'Fan Speed\n',
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
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
                                          Center(
                                            child: Text("50%",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4),
                                          )
                                        ],
                                      )),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    'Dial\n',
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
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
                                          Center(
                                            child: Text("50%",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4),
                                          )
                                        ],
                                      ))
                                ],
                              )
                            ],
                          ),
                          Text("\nLast updated: sec ago..\n")
                        ]),
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
                                )
                              ],
                            )))
                  ],
                ),
              ),
            )));
  }
}

class BleDeviceItem {
  String deviceName;
  Peripheral peripheral;
  int rssi;
  AdvertisementData advertisementData;
  BleDeviceItem(this.deviceName, this.rssi, this.peripheral, this.advertisementData);
}
