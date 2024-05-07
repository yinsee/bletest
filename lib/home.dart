import 'dart:async';

import 'package:bletest/const.dart';
import 'package:bletest/data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final List<ScanResult> _devices = [];
  StreamSubscription<List<ScanResult>>? _scanresult;
  final ValueListenable<List<BluetoothDevice>> _devices = ValueNotifier([]);
  final rssi = {};

  @override
  void initState() {
    _scanresult = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          // update rssi
          results.forEach((_) => rssi[_.device.remoteId] = _.rssi);

          ScanResult r = results.last; // the most recently found device
          if (!r.advertisementData.connectable) return;
          if (!r.advertisementData.serviceUuids.any((_) => _ == kServiceUUID))
            return;
          final dev = r.device;
          setState(() {
            try {
              var _ =
                  _devices.value.firstWhere((d) => d.remoteId == dev.remoteId);
            } catch (e) {
              _devices.value.add(dev);
            }
          });
        }
      },
      onError: (e) => print(e),
    );

    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print(state);
      if (state == BluetoothAdapterState.on) {
        FlutterBluePlus.startScan();
        // usually start scanning, connecting, etc
      } else {
        // show an error to the user, etc
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    // _stream?.cancel();
    _scanresult?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan for devices')),
      body: ValueListenableBuilder(
          valueListenable: _devices,
          builder: (context, devices, child) {
            if (devices.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.separated(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("${devices[index].platformName}"),
                  subtitle: Text("${devices[index].remoteId}"),
                  trailing: rssi.containsKey(devices[index].remoteId)
                      ? RssiWidget(rssi[devices[index].remoteId])
                      : null,
                  onTap: () async {
                    FlutterBluePlus.stopScan();
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            DeviceData(device: devices[index]),
                      ),
                    );
                    setState(() {
                      _devices.value.clear();
                    });
                    FlutterBluePlus.startScan();
                  },
                );
              },
              separatorBuilder: (_, __) => Divider(),
              itemCount: devices.length,
            );
          }),
    );
  }
}

class RssiWidget extends StatelessWidget {
  final int rssi;

  const RssiWidget(
    this.rssi, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    Color color = Colors.green;
    if (rssi > -70) {
      icon = Icons.wifi_rounded;
    } else if (rssi > -100) {
      icon = Icons.wifi_2_bar_rounded;
      color = Colors.amber;
    } else {
      icon = Icons.wifi_1_bar_rounded;
      color = Colors.red;
    }
    return Icon(icon, color: color);
  }
}
