import 'package:lib_sysfs_usb/ports.dart';
import 'dart:io';
import 'package:lib_sysfs_usb/usb-bus.dart';

void main(List<String> arguments) {
  test();
}

Future<void> test() async {
  try {
    var busList = await UsbBus.getBuses();
    print(busList);

    for (var bus in busList) {
      await bus.init();

      bus.printData();
      print("");

      var portList = await bus.getPorts();

      for (var port in portList) {
        if (await port.isConnected()) {
          await port.init();
          // port.printData();
          print("");

          var device = await port.getDevice();
          if (device != null) {
            await device.init();
            device.printData();
          }
        }
      }

      // bus.printData();

      // print("         Port: ${port.portNum}");
      // print("    Connected: ${await port.isConnected()}");
      // if (await port.isConnected()) {
      //   print(" Manufacturer: ${await port.deviceManufacturer}");
      //   print("      Product: ${await port.deviceProduct}");
      //   print("       Serial: ${await port.deviceSerialNum}");

      //   print("    Max power: ${await port.deviceMaxPower}");
      //   print("      Version: ${await port.deviceVersion}");
      //   print("        Speed: ${await port.deviceSpeed}");
      //   print("    Removable: ${await port.deviceRemovable}");
      // }
      print("");
    }

    // var usbBuses = await Ports.getUsbBuses();
    // print("Usb bus count: ${ports.usbBusCount}");
    // for (var bus in usbBuses) {
    //   await bus.init();
    //   print(" Bus number: ${bus.busNum}");

    //   print("  Bus speed: ${bus.speed}");

    //   print(" Port count: ${bus.busPortCount}");
    //   print("  Bus speed: ${bus.version}");

    //   // await bus.printData();
    //   var busPorts = await bus.getPorts();

    //   for (var port in busPorts) {
    //     await port.init();

    //     print("  Port id: ${port.portNum}");
    //     print("  Port c: ${port.busPortCount}");
    //     print("  Connected: ${await port.isConnected()}");
    //     print("");

    //     if (await port.isConnected()) {
    //       var man = await port.manufacturer;
    //       print("manufacturer: $man");
    //     }

    //     // await port.printData();
    //   }
    // }
  } catch (e) {
    print(e);
  }

  // try {
  //   var usbCList = await Ports.getUsbC();
  //   print("Usb-C port count: ${ports.usbCPorts}");

  //   for (var port in usbCList) {
  //     await port.init();
  //     await port.printData();
  //   }
  // } catch (e) {
  //   print(e);
  // }
}
