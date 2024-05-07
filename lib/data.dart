import 'dart:async';
import 'dart:convert';

import 'package:bletest/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceData extends StatefulWidget {
  final BluetoothDevice device;
  const DeviceData({required this.device, super.key});

  @override
  State<DeviceData> createState() => _DeviceDataState();
}

class _DeviceDataState extends State<DeviceData> {
  late BluetoothDevice _device;
  StreamSubscription<List<int>>? _sub;
  final ValueNotifier _value = ValueNotifier('...');

  @override
  void dispose() {
    _device.disconnect();
    _sub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _device = widget.device;
    _init();

    super.initState();
  }

  _init() async {
    if (!_device.isConnected) {
      await _device.connect();
    }

    try {
      List<BluetoothService> services = await _device.discoverServices();
      final c = services
          .firstWhere((s) => s.serviceUuid == kServiceUUID)
          .characteristics
          .firstWhere((c) => c.uuid == kCharactersticUUID)
        ..setNotifyValue(true);
      _sub = c.onValueReceived.listen((event) {
        _value.value = utf8.decode(event);
      });
      _device.cancelWhenDisconnected(_sub!);
    } catch (e) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_device.platformName)),
      body: ValueListenableBuilder(
          valueListenable: _value,
          builder: (context, value, child) {
            return Center(
                child: Text(
              value,
              style: Theme.of(context).textTheme.displayLarge,
            ));
          }),
    );
  }
}
