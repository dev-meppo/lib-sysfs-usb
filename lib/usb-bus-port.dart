import 'dart:io';
import 'package:lib_sysfs_usb/read-file.dart';
import 'package:lib_sysfs_usb/usb-device.dart';

class UsbBusPort {
  late final String _sysUsbDevicePath;
  late final String _sysBusPath;
  final int busNum;
  int? busPortCount;
  int? portNum;

  late final Map<String, String> _sysPathMap = {
    "maxchild": "$_sysBusPath/maxchild",
  };
  late final Map<String, dynamic> _sysDataMap = {
    "maxchild": null,
  };

  late final Map<String, dynamic> _sysUsbDevicePathMap = {
    "state": "$_sysUsbDevicePath/usb$busNum-port$portNum/state",
  };

  UsbBusPort(this.busNum) {
    _sysBusPath = "/sys/bus/usb/devices/usb$busNum";
    _sysUsbDevicePath = "/sys/bus/usb/devices/usb$busNum/$busNum-0:1.0";
  }

  Future<void> init() async {
    await _readSysData();
  }

  Future<List<UsbBusPort>> getPorts() async {
    List<UsbBusPort> portsList = [];

    int i = 1;
    if (busPortCount != null) {
      while (i <= busPortCount!) {
        var usbPort = UsbBusPort(busNum);
        usbPort.portNumber = i;
        portsList.add(usbPort);
        i += 1;
      }
    } else {
      throw (Exception("(UsbBus)-> Not initialized."));
    }

    return portsList;
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
        data = data.trim();

        switch (key) {
          case "maxchild":
            //  print("Case: $key!");
            data = int.parse(data);
            busPortCount = data;
          case "state":
          //  print("Case: $key!");

          default:
            if (_sysDataMap.containsKey(key)) {
              _sysDataMap[key] = data;
            } else {
              //  print("No key found: $key");
            }
        }
      }
    }
  }

  Future<bool> isConnected() async {
    var data = await readSysFile(_sysUsbDevicePathMap["state"]!);

    if (data != null) {
      data = data.trim();

      if (data == "not attached") {
        return false;
      } else {
        return true;
      }
    } else {
      print("(isConnected)-> Got null");
      return false;
    }
  }

  Future<UsbDevice?> getDevice() async {
    if (await isConnected()) {
      var device = UsbDevice(
        busNum,
        portNum,
      );
      return device;
    } else {
      return null;
    }
  }

  set portNumber(int portNumber) {
    portNum = portNumber;
  }

  void printData() {
    print("        Bus: $busNum");
    print("       Port: $portNum");
    print(" Port count: $busPortCount");
  }
}
