import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

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
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BleDeviceItem> deviceList = []; // Array that hold ble devices.
  BluetoothDevice bleDevice;
  bool bleConnected = false;
  bool isScanning = false;

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

  void initState() {
    checkPermissions();
    scan(); //Ble Scan
    super.initState();
  }

  checkPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.contacts.request().isGranted) {}
      Map<Permission, PermissionStatus> statuses =
      await [Permission.location].request();
      print(statuses[Permission.location]);
    }
  }

  void scan() async {
    if(!isScanning) {
      print("Scan Start");
      isScanning = true;
      // Start scanning
      flutterBlue.startScan(timeout: Duration(seconds: 10));
      // Listen to scan results
      flutterBlue.scanResults.listen((results) {
        // do something with scan results
        for (ScanResult r in results) {
          print(r);
          var name = r.device.name ?? r.advertisementData.localName;
          if (name == "") name = "Unknown";
          //print(r.device.name + ":" + r.advertisementData.localName);
          var findDevice = deviceList.any((element) {
            if (element.device.id == r.device.id) {
              element.deviceName = name;
              element.device = r.device;
              element.rssi = r.rssi;
              element.advertisementData = r.advertisementData;
              return true;
            }
            return false;
          });
          if (!findDevice) {
            deviceList
                .add(
                BleDeviceItem(name, r.device, r.rssi, r.advertisementData));
          }
          setState(() {});
        }
        isScanning = false;
      });
      // Stop scanning
      flutterBlue.stopScan();
    }
  }

  void bleConnect (BluetoothDevice bleDev) {
    if(bleConnected) {
      print("Disconnecting the device \"" + bleDevice.name + "\"");
      bleConnected = false;
      if(bleDevice == bleDev)
        return;
    }
    print("connecting");
    bleDevice = bleDev;
    var status = bleDev.connect();
    bleConnected = true;
  }

  list() {
    return ListView.builder(
      //shrinkWrap: true,
      itemCount: deviceList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(deviceList[index].deviceName),
          subtitle: Text(deviceList[index].device.id.toString()),
          trailing: Text("${deviceList[index].rssi}"),
          onTap: () {
            bleConnect(deviceList[index].device);
          },
        );
      },
    );
  }

  void _onItemTapped(int i) {
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
                  child: Expanded(child: list())),
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
          onTap: _onItemTapped,
        ),
        floatingActionButton: Visibility(
          visible: tabIndex == 0,
          child: FloatingActionButton(
            onPressed: () {
              if (!isScanning)
                scan();
            },
            child: Icon(Icons.bluetooth),
            backgroundColor: Colors.cyan,
          ),
        ));
  }
}

class BleDeviceItem {
  // Ble Information
  String deviceName;
  BluetoothDevice device;
  int rssi;
  AdvertisementData advertisementData;

  BleDeviceItem(
      this.deviceName, this.device, this.rssi, this.advertisementData);
}
