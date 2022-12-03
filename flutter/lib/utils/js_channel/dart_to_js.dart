import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

///
/// DartToJs
///
/// Created by Jack Zhang on 2022/11/28 .
///
class DartToJs {
  factory DartToJs() => _getInstance();

  DartToJs._internal();

  static DartToJs get instance => _getInstance();
  static DartToJs? _instance;

  static DartToJs _getInstance() {
    _instance ??= DartToJs._internal();
    return _instance!;
  }

  InAppWebViewController? controller;

  Future<void> onReceiveNotification(String title, String content, int notificationId) async {
    try {
      Map<String, dynamic> data = {
        'title': title,
        'content': content,
        'notificationId': notificationId,
      };
      await dispatchJsEvent(event: JsEvents.onReceiveNotification, data: data);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> onBleStatusChanged(bool status) async {
    try {
      Map<String, dynamic> data = {
        'status': status,
      };
      await dispatchJsEvent(event: JsEvents.onBleStatusChanged, data: data);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> onScanNewDevice(DiscoveredDevice device) async {
    try {
      Map<String, dynamic> data = {
        'id': device.id,
        'name': device.name,
      };
      await dispatchJsEvent(event: JsEvents.onScanNewDevice, data: data);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> onBleDeviceStatusChanged(String deviceId, int status, String? msg) async {
    try {
      Map<String, dynamic> data = {
        'deviceId': deviceId,
        'status': status,
        'msg': msg,
      };
      await dispatchJsEvent(event: JsEvents.onBleDeviceStatusChanged, data: data);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // native向JavaScript发送数据
  Future<void> dispatchJsEvent({
    required String event,
    required Map<String, dynamic> data,
  }) async {
    if (controller == null) {
      return;
    }
    try {
      String jsonData = jsonEncode(data);
      var response = await controller!.callAsyncJavaScript(
        functionBody: """
            const event = new CustomEvent("$event", {
              detail: $jsonData
            });
            window.dispatchEvent(event);
          """,
      );
      if (response?.error != null) {
        debugPrint(response?.error ?? "");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

class JsEvents {
  /// 收到通知消息
  static String onReceiveNotification = 'r_pushOnReceiveNotification';
  /// 手机蓝牙状态更新
  static String onBleStatusChanged = 'r_bleOnBleStatusChanged';
  /// 发现新的蓝牙设备
  static String onScanNewDevice = 'r_bleOnScanNewDevice';
  /// 目标蓝牙设备状态更新
  static String onBleDeviceStatusChanged = 'r_bleOnBleDeviceStatusChanged';
}
