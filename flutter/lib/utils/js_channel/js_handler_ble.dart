import 'package:flutter_browser/utils/ble/ble_util.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

///
/// 蓝牙相关JS Handler
///
/// Created by Jack Zhang on 2022/11/28 .
///
void registerJsHandlerBle(InAppWebViewController controller) {
  // 设备蓝牙初始化（使用蓝牙功能前，必须优先调用）
  controller.addJavaScriptHandler(
      handlerName: 's_bleInit',
      callback: (List<dynamic> arguments) {
        BleUtil.instance.init();
      });
  // 扫描蓝牙设备
  controller.addJavaScriptHandler(
      handlerName: 's_bleStartScanDevices',
      callback: (List<dynamic> arguments) {
        BleUtil.instance.startScan();
      });
  // 停止扫描蓝牙设备
  controller.addJavaScriptHandler(
      handlerName: 's_bleStopScanDevices',
      callback: (List<dynamic> arguments) async {
        await BleUtil.instance.stopScan();
      });
  // 连接蓝牙设备
  controller.addJavaScriptHandler(
      handlerName: 's_bleConnectDevice',
      callback: (List<dynamic> arguments) {
        String deviceId = arguments.first;
        BleUtil.instance.connect(deviceId);
      });
  // 断开连接蓝牙设备
  controller.addJavaScriptHandler(
      handlerName: 's_bleDisconnectDevice',
      callback: (List<dynamic> arguments) async {
        String deviceId = arguments.first;
        await BleUtil.instance.disconnect(deviceId);
      });
}
