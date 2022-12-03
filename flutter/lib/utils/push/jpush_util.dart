import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_browser/utils/js_channel/dart_to_js.dart';
import 'package:flutter_browser/utils/js_channel/js_handler.dart';
import 'package:flutter_browser/webview_tab.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

///
/// JPushUtil
///
/// Created by Jack Zhang on 2022/11/26 .
///
class JPushUtil {
  factory JPushUtil() => _getInstance();

  JPushUtil._internal() {
    jpush = JPush();
  }

  static JPushUtil get instance => _getInstance();
  static JPushUtil? _instance;

  static JPushUtil _getInstance() {
    _instance ??= JPushUtil._internal();
    return _instance!;
  }

  late final JPush jpush;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    try {
      jpush.addEventHandler(onReceiveNotification: (Map<String, dynamic> message) async {
        debugPrint("flutter onReceiveNotification: $message");
        DartToJs.instance.onReceiveNotification(message['title'], message['alert'], message['extras']['cn.jpush.android.NOTIFICATION_ID']);
      }, onOpenNotification: (Map<String, dynamic> message) async {
        debugPrint("flutter onOpenNotification: $message");
      }, onReceiveMessage: (Map<String, dynamic> message) async {
        debugPrint("flutter onReceiveMessage: $message");
      }, onReceiveNotificationAuthorization: (Map<String, dynamic> message) async {
        debugPrint("flutter onReceiveNotificationAuthorization: $message");
      });
    } on PlatformException {
      debugPrint('Failed to get platform version.');
    }

    jpush.setup(
      appKey: '9e3e0da905fbcf63c10f9d9c',
      channel: "developer-default",
      production: !isDebug,
      debug: isDebug,
    );
    jpush.applyPushAuthority(const NotificationSettingsIOS(sound: true, alert: true, badge: true));

    // Platform messages may fail, so we use a try/catch PlatformException.
    jpush.getRegistrationID().then((rid) {
      debugPrint("flutter get registration id : $rid");
    });
  }

  /// 设置别名
  void setAlias(String alias) {
    jpush.setAlias(alias);
  }

  /// 清除别名
  void deleteAlias() {
    jpush.deleteAlias();
  }

  /// 停止接收推送
  void stopPush() {
    jpush.stopPush();
  }

  /// 恢复推送功能
  void resumePush() {
    jpush.resumePush();
  }

  /// 清空通知栏上的所有通知
  void clearAllNotifications() {
    jpush.clearAllNotifications();
  }

  /// 清空通知栏上的指定通知
  void clearNotification(int notificationId) {
    jpush.clearNotification(notificationId: notificationId);
  }

  /// 检测通知授权状态是否打开
  Future<bool> isNotificationEnabled() {
    return jpush.isNotificationEnabled();
  }

  /// 跳转至系统设置中应用设置界面
  void openSettingsForNotification() {
    jpush.openSettingsForNotification();
  }
}
