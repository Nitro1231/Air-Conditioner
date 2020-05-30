import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
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
  BleManager bleManager = BleManager();
  bool isScanning= false;
  List<BleDeviceItem> deviceList = []; // Array that hold ble devices.

  mode controlMode = mode.Auto;
  bool bleConnected = true;
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
    init(); //BLE 초기화
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
        .then((_) => checkPermissions()) //Checking Permission
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

  void scan() async {
    if(!isScanning) {
      deviceList.clear(); // ??
      bleManager.startPeripheralScan().listen((scanResult) {
        /* Information that we can obtain
        Name: scanResult.peripheral.name or scanResult.advertisementData.localName
        RSSI: scanResult.rssi
        MAC Address: scanResult.peripheral.identifier
        UUID: scanResult.advertisementData.serviceUuids
        Manufacture Data: scanResult.advertisementData.manufacturerData
        Tx Power Level: scanResult.advertisementData.txPowerLevel
        scanResult.peripheral
         */

        // Check name from Peripheral data and Advertisement Data, if the name dose not exist, display it as "Unknown"
        var name = scanResult.peripheral.name ?? scanResult.advertisementData.localName ?? "Unknown";

        // Check the device from the Mac Address
        var findDevice = deviceList.any((element) {
          // Check if Device is already exist in the deviceList.
          if(element.peripheral.identifier == scanResult.peripheral.identifier) {
            // Update information
            element.peripheral = scanResult.peripheral;
            element.advertisementData = scanResult.advertisementData;
            element.rssi = scanResult.rssi;
            print("???");
            return true;
          }
          return false;
        });
        // If the device never detected, add to the list
        if(!findDevice) {
          deviceList.add(BleDeviceItem(name, scanResult.rssi, scanResult.peripheral, scanResult.advertisementData));
        }
        setState((){});
      });
      setState(() { isScanning = true; });
    }
    else {
      bleManager.stopPeripheralScan();
      setState(() { isScanning = false; });
    }
  }

  list() {
    return ListView.builder(
      itemCount: deviceList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text("!" + deviceList[index].deviceName),
          subtitle: Text("!" + deviceList[index].peripheral.identifier),
          trailing: Text("!${deviceList[index].rssi}"),
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
                child: list()
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
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.cyan),
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
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.cyan),
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
                                        trackShape:
                                        RectangularSliderTrackShape(),
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
    );
  }
}

class BleDeviceItem { // Ble Information
  String deviceName;
  Peripheral peripheral;
  int rssi;
  AdvertisementData advertisementData;
  BleDeviceItem(this.deviceName, this.rssi, this.peripheral, this.advertisementData);
}