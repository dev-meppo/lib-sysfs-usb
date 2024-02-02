import 'dart:io';
import 'package:lib_sysfs_usb/read-file.dart';

class UsbDevice {
  late final String _sysUsbDevicePath;
  late final String _sysBusPath;
  final int busNum;
  int? busPortCount;
  int? portNum;

  late final Map<String, dynamic> _sysDynamicDataMap = {
    "manufacturer": null,
    "product": null,
    "bMaxPower": null,
    "serial": null,
    "version": null,
    "speed": null,
    "removable": null,
    "maxchild": null,
    "isHub": null,
    "ltm_capable": null,
    "bMaxPacketSize0": null,
    "active_duration": null,
    "connected_duration": null,
    "runtime_status": null,
    "autosuspend_delay_ms": null,
    "control": null,
  };

  late final Map<String, String> _sysPathMap = {
    "maxchild": "$_sysBusPath/maxchild",
  };
  late final Map<String, dynamic> _sysDataMap = {
    "maxchild": null,
  };

  late final Map<String, dynamic> _sysUsbDevicePathMap = {
    "manufacturer":
        "$_sysUsbDevicePath/usb$busNum-port$portNum/device/manufacturer",
    "state": "$_sysUsbDevicePath/usb$busNum-port$portNum/state",
    "product": "$_sysUsbDevicePath/usb$busNum-port$portNum/device/product",
    "bMaxPower": "$_sysUsbDevicePath/usb$busNum-port$portNum/device/bMaxPower",
    "serial": "$_sysUsbDevicePath/usb$busNum-port$portNum/device/serial",
    "version": "$_sysUsbDevicePath/usb$busNum-port$portNum/device/version",
    "speed": "$_sysUsbDevicePath/usb$busNum-port$portNum/device/speed",
    "removable": "$_sysUsbDevicePath/usb$busNum-port$portNum/device/removable",
    "maxchild": "$_sysUsbDevicePath/usb$busNum-port$portNum/device/maxchild",
    "ltm_capable":
        "$_sysUsbDevicePath/usb$busNum-port$portNum/device/ltm_capable",
    "bMaxPacketSize0":
        "$_sysUsbDevicePath/usb$busNum-port$portNum/device/bMaxPacketSize0",
    "active_duration":
        "$_sysUsbDevicePath/usb$busNum-port$portNum/device/power/active_duration",
    "connected_duration":
        "$_sysUsbDevicePath/usb$busNum-port$portNum/device/power/connected_duration",
    "runtime_status":
        "$_sysUsbDevicePath/usb$busNum-port$portNum/device/power/runtime_status",
    "autosuspend_delay_ms":
        "$_sysUsbDevicePath/usb$busNum-port$portNum/device/power/autosuspend_delay_ms",
    "control":
        "$_sysUsbDevicePath/usb$busNum-port$portNum/device/power/control",
  };

  UsbDevice(this.busNum, this.portNum) {
    _sysBusPath = "/sys/bus/usb/devices/usb$busNum";
    _sysUsbDevicePath = "/sys/bus/usb/devices/usb$busNum/$busNum-0:1.0";
  }

  Future<void> init() async {
    await _readSysData();
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

    for (var entry in _sysUsbDevicePathMap.entries) {
      key = entry.key;
      path = entry.value;
      data = await readSysFile(path);

      if (data != null) {
        if (_sysDynamicDataMap.containsKey(key)) {
          switch (key) {
            case "removable":
              if (data == "fixed") {
                _sysDynamicDataMap[key] = bool.parse("false");
              } else {
                _sysDynamicDataMap[key] = bool.parse("true");
              }
            case "ltm_capable":
              if (data == "no") {
                _sysDynamicDataMap[key] = bool.parse("false");
              } else if (data == "yes") {
                _sysDynamicDataMap[key] = bool.parse("true");
              }
            case "bMaxPacketSize0":
              _sysDynamicDataMap[key] = int.parse(data);
            case "maxchild":
              data = int.parse(data);
              _sysDynamicDataMap[key] = data;
              if (data > 0) {
                _sysDynamicDataMap["isHub"] = bool.parse("true");
              } else {
                _sysDynamicDataMap["isHub"] = bool.parse("false");
              }

            default:
              _sysDynamicDataMap[key] = data;
          }
        } else {
          // print("No key found: $key");
        }
      }
    }
  }

  void printData() {
    print("          Bus: $busNum");
    print("         Port: $portNum");

    print(" Manufacturer: ${_sysDynamicDataMap["manufacturer"]}");
    print("      Product: ${_sysDynamicDataMap["product"]}");
    print("       Serial: ${_sysDynamicDataMap["serial"]}");
    print("    Max power: ${_sysDynamicDataMap["bMaxPower"]}");
    print("        Speed: ${_sysDynamicDataMap["speed"]}");
    print(" Is Removable: ${_sysDynamicDataMap["removable"]}");
    print("Is ltm capabled: ${_sysDynamicDataMap["ltm_capable"]}");
    print("       Is hub: ${_sysDynamicDataMap["isHub"]}");
    print("    Max child: ${_sysDynamicDataMap["maxchild"]}");
    print("      control: ${_sysDynamicDataMap["control"]}");
    print("      Version: ${_sysDynamicDataMap["version"]}");
    print("bMaxPacketSize0d: ${_sysDynamicDataMap["bMaxPacketSize0"]}");
    print(" active_duration: ${_sysDynamicDataMap["active_duration"]} MS");
    print(
        " connected_duration: ${_sysDynamicDataMap["connected_duration"]} MS");
    print(" runtime_status: ${_sysDynamicDataMap["runtime_status"]}");
    print(
        " autosuspend_delay_ms: ${_sysDynamicDataMap["autosuspend_delay_ms"]}");
  }
}
