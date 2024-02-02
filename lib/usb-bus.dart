import 'dart:io';
import 'package:lib_sysfs_usb/read-file.dart';
import 'package:lib_sysfs_usb/usb-device.dart';
import 'package:lib_sysfs_usb/usb-bus-port.dart';

class UsbBus {
  late final String _sysPath;
  final int busNum;
  int? busPortCount;
  int? speed;
  String? version;

  late final Map<String, String> _sysPathMap = {
    "version": "$_sysPath/version",
    "speed": "$_sysPath/speed",
    "maxchild": "$_sysPath/maxchild",
  };
  late final Map<String, dynamic> _sysDataMap = {
    "version": null,
    "speed": null,
    "maxchild": null,
  };

  UsbBus(this.busNum) {
    _sysPath = "/sys/bus/usb/devices/usb$busNum";
  }

  Future<void> init() async {
    await _readSysData();
  }

  void printData() {
    print("        Bus: $busNum");
    print(" Port count: $busPortCount");
    print("      Speed: $speed");
    print("    Version: $version");
  }

  Future<List<UsbBusPort>> getPorts() async {
    var busPorts = UsbBusPort(busNum);
    await busPorts.init();

    return busPorts.getPorts();
  }

  static Future<List<UsbBus>> getBuses() async {
    List<UsbBus> busList = [];

    int i = 1;
    while (await Directory("/sys/bus/usb/devices/usb$i").exists()) {
      busList.add(UsbBus(i));
      print("Bus $i exists!");
      i += 1;
    }

    return busList;
  }

  Future<void> _readSysData() async {
    dynamic data;
    String key;

    String path;

    for (var entry in _sysPathMap.entries) {
      key = entry.key;
      path = entry.value;
      data = await readSysFile(path);

      if (data != null) {
        data = data.trim(); // Assign the trimmed string back to data
        switch (key) {
          case "maxchild":
            // print("Case: $key!");
            data = int.parse(data);
            busPortCount = data;

          case "speed":
            // print("Case: $key!");
            data = int.parse(data);
            speed = data;

          case "version":
            // print("Case: $key!");
            version = data;
        }

        if (_sysDataMap.containsKey(key)) {
          _sysDataMap[key] = data;
        } else {
          print("No key found: $key");
        }
      }
    }
  }
}
