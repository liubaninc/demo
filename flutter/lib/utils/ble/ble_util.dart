import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_browser/utils/js_channel/dart_to_js.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

///
/// BleUtil
///
/// Created by Jack Zhang on 2022/11/26 .
///
class BleUtil {
  static const String tag = 'BleUtil';

  factory BleUtil() => _getInstance();

  BleUtil._internal() {
    ble = FlutterReactiveBle();
    statusStream.listen((BleStatus status) {
      _debugPrint(status.toString());
      if (_jsEnabled) {
        _sendBleStatus(status);
      }
    });
  }

  static BleUtil get instance => _getInstance();
  static BleUtil? _instance;

  static BleUtil _getInstance() {
    _instance ??= BleUtil._internal();
    return _instance!;
  }

  late final FlutterReactiveBle ble;

  List<DiscoveredDevice> bleDiscoveredDevicesList = <DiscoveredDevice>[];

  Stream<BleStatus> get statusStream => ble.statusStream;

  bool _jsEnabled = false;

  StreamSubscription<DiscoveredDevice>? _subscription;
  StreamSubscription<ConnectionStateUpdate>? _connection;

  Future init() async {
    await _askBlePermission();
    _jsEnabled = true;
    _sendBleStatus(ble.status);
  }

  void _sendBleStatus(BleStatus status) {
    DartToJs.instance.onBleStatusChanged(status == BleStatus.ready);
  }

  Future _askBlePermission() async {
    var blePermission = await Permission.bluetooth.status;
    if (blePermission.isDenied) {
      Permission.bluetooth.request();
    }
    // Android Vr > 12 required These Ble Permission
    if (Platform.isAndroid) {
      var bleConnectPermission = await Permission.bluetoothConnect.status;
      var bleScanPermission = await Permission.bluetoothScan.status;
      if (bleConnectPermission.isDenied) {
        Permission.bluetoothConnect.request();
      }
      if (bleScanPermission.isDenied) {
        Permission.bluetoothScan.request();
      }
    }
    if (await Permission.location.serviceStatus.isEnabled) {
      _debugPrint('Location services is enabled');
    } else {
      _debugPrint('Location services is NOT enabled');
    }
    var status = await Permission.location.status;
    if (status.isDenied) {
      Permission.location.request();
    }
  }

  void startScan({List<Uuid>? services}) async {
    _subscription?.cancel();
    _subscription = ble.scanForDevices(withServices: services ?? [], scanMode: ScanMode.balanced).listen((DiscoveredDevice device) {
      if (device.name.isNotEmpty) {
        _debugPrint(device.toString());
        DartToJs.instance.onScanNewDevice(device);
      }
    }, onError: (e) {
      _debugPrint(e.toString());
    });
  }

  Future stopScan() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future connect(String deviceId) async {
    await _connection?.cancel();
    _connection = ble.connectToDevice(id: deviceId, connectionTimeout: const Duration(seconds: 5)).listen((ConnectionStateUpdate update) {
      if (update.failure != null) {
        DartToJs.instance.onBleDeviceStatusChanged(update.deviceId, -1, update.failure!.message);
      } else {
        DartToJs.instance.onBleDeviceStatusChanged(update.deviceId, update.connectionState.index, null);
      }
    }, onError: (error) {
      if (error is TimeoutException) {
        DartToJs.instance.onBleDeviceStatusChanged(deviceId, -1, '连接超时');
      } else {
        DartToJs.instance.onBleDeviceStatusChanged(deviceId, -1, error.toString());
      }
      _debugPrint(error.toString());
    });
  }

  Future disconnect(String deviceId) async {
    await _connection?.cancel();
    // 手动发送一个断开连接事件
    DartToJs.instance.onBleDeviceStatusChanged(deviceId, DeviceConnectionState.disconnected.index, null);
    _connection = null;
  }

  /// 日志打印
  void _debugPrint(String msg) {
    debugPrint('$tag: $msg');
  }
}
