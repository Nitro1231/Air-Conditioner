import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Air Conditioner Controller';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyan,
        accentColor: Colors.cyan,
      ),
      home: MyStatefulWidget(
        title: _title,
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

enum mode { Auto, Dial, Bluetooth }
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  Timer discoverableTimeoutTimer;
  StreamSubscription<BluetoothDiscoveryResult> streamSubscription;
  List<BluetoothDiscoveryResult> deviceList = List<BluetoothDiscoveryResult>();
  bool isDiscovering = false;
  bool bleConnected = false;

  mode controlMode = mode.Auto;
  int tabIndex = 0;
  double outsideTemp = 0;
  double insideTemp = 0;
  double fanSpeed = 0;
  double offset = 0;

  static const TextStyle h6 = TextStyle(fontSize: 40);
  static const TextStyle h3 =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const TextStyle h4 =
      TextStyle(fontSize: 25, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();

    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        discoverableTimeoutTimer = null;
      });
    });
    scan();
    //scan(); //Ble Scan
  }

  void scan() {
    if (!isDiscovering) {
      isDiscovering = true;
      streamSubscription =
          FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
            setState(() {
              deviceList.add(r);
              print(r.device.name);
            });
          });
      streamSubscription.onDone(() {
        setState(() {
          isDiscovering = false;
        });
      });
    }
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    discoverableTimeoutTimer?.cancel();

    // Avoid memory leak (`setState` after dispose) and cancel discovery
    streamSubscription?.cancel();
    super.dispose();
  }

  void onItemTapped(int i) {
    setState(() {
      tabIndex = i;
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
            children: <Widget>[
              Visibility(
                visible: tabIndex == 0, // Shows this page when tabIndex is 0.
                child: Column(
                  children: <Widget>[
                    SwitchListTile(
                      title: const Text('Enable Bluetooth'),
                      value: _bluetoothState.isEnabled,
                      onChanged: (bool value) {
                        // Do the request and update with the true value then
                        future() async {
                          // async lambda seems to not working
                          if (value)
                            await FlutterBluetoothSerial.instance.requestEnable();
                          else
                            await FlutterBluetoothSerial.instance.requestDisable();
                        }
                        future().then((_) {
                          setState(() {});
                        });
                      },
                    ),
                    ExpansionTile(
                        leading: Icon(Icons.devices),
                        title: Text('Scanned Bluetooth Devices'),
                        children: <Widget>[

                        ]
                    ),
                    ExpansionTile(
                        leading: Icon(Icons.link),
                        title: Text('Paired Devices'),
                        children: <Widget>[

                        ]
                    )
                  ],
                ),
                //child: Expanded(child: list())
              ),
              Visibility(
                visible: tabIndex == 1, // Shows this page when tabIndex is 1.
                child: (AnimatedOpacity(
                  opacity: bleConnected ? 1.0 : 0.4,
                  duration: Duration(milliseconds: 500),
                  child: AbsorbPointer(
                    absorbing: !bleConnected,
                    child: Scrollbar(
                      child: Center(
                          child: GridView.count(
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
                                              child: CircularProgressIndicator(
                                                value: 0.5,
                                                backgroundColor: Colors.black12,
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
                                              child: CircularProgressIndicator(
                                                value: 0.5,
                                                backgroundColor: Colors.black12,
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
                      )),
                    ),
                  ),
                )),
              ),
              Visibility(
                  visible: tabIndex == 2, // Shows this page when tabIndex is 2.
                  child: AnimatedOpacity(
                      opacity: bleConnected ? 1.0 : 0.4,
                      duration: Duration(milliseconds: 500),
                      child: AbsorbPointer(
                        absorbing: !bleConnected,
                        child: ListView(shrinkWrap: true, children: <Widget>[
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
                                      });
                                    },
                                  ),
                                )
                              ]),
                          AnimatedOpacity(
                              opacity:
                                  (controlMode == mode.Bluetooth) ? 1.0 : 0.4,
                              duration: Duration(milliseconds: 500),
                              child: AbsorbPointer(
                                  absorbing: !(controlMode == mode.Bluetooth),
                                  child: ExpansionTile(
                                    leading: Icon(Icons.computer),
                                    title: Text('Control'),
                                    children: <Widget>[
                                      SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          activeTrackColor: Colors.cyan[700],
                                          inactiveTrackColor: Colors.black54,
                                          trackShape:
                                              RectangularSliderTrackShape(),
                                          trackHeight: 4.0,
                                          thumbColor: Colors.cyan,
                                          thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius: 12.0),
                                          overlayColor:
                                              Colors.cyan.withAlpha(32),
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
                                          trackShape:
                                              RectangularSliderTrackShape(),
                                          trackHeight: 4.0,
                                          thumbColor: Colors.cyan,
                                          thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius: 12.0),
                                          overlayColor:
                                              Colors.cyan.withAlpha(32),
                                          overlayShape: RoundSliderOverlayShape(
                                              overlayRadius: 28.0),
                                        ),
                                        child: Slider(
                                          min: 0,
                                          max: 255,
                                          value: offset,
                                          onChanged: (value) {
                                            setState(() {
                                              offset = value;
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  )))
                        ]),
                      )))
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
          currentIndex: tabIndex,
          selectedItemColor: Colors.cyan,
          backgroundColor: Colors.black45,
          onTap: onItemTapped,
        ),
        floatingActionButton: Visibility(
          visible: tabIndex == 0,
          child: FloatingActionButton(
            onPressed: () {
              //if (!isScanning) scan();
            },
            child: Icon(Icons.bluetooth),
            backgroundColor: Colors.cyan,
          ),
        ));
  }
}

/*
class BleDeviceItem {
  // Ble Information
  String deviceName;
  BluetoothDevice device;
  int rssi;
  AdvertisementData advertisementData;

  BleDeviceItem(
      this.deviceName, this.device, this.rssi, this.advertisementData);
}*/
