import 'package:flutter_browser/utils/push/jpush_util.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

///
/// 推送相关JS Handler
///
/// Created by Jack Zhang on 2022/11/28 .
///
void registerJsHandlerPush(InAppWebViewController controller) {
  // 设置别名（登录成功后调用）
  controller.addJavaScriptHandler(
      handlerName: 's_pushSetAlias',
      callback: (List<dynamic> arguments) {
        String alias = arguments.first;
        JPushUtil.instance.setAlias(alias);
      });
  // 清除别名（登出后调用）
  controller.addJavaScriptHandler(
      handlerName: 's_pushDeleteAlias',
      callback: (List<dynamic> arguments) {
        JPushUtil.instance.deleteAlias();
      });
  // 停止接收推送
  controller.addJavaScriptHandler(
      handlerName: 's_pushStop',
      callback: (List<dynamic> arguments) {
        JPushUtil.instance.stopPush();
      });
  // 恢复推送功能
  controller.addJavaScriptHandler(
      handlerName: 's_pushResume',
      callback: (List<dynamic> arguments) {
        JPushUtil.instance.resumePush();
      });
  // 清空通知栏上的所有通知
  controller.addJavaScriptHandler(
      handlerName: 's_pushClearAllNotifications',
      callback: (List<dynamic> arguments) {
        JPushUtil.instance.clearAllNotifications();
      });
  // 清空通知栏上的指定通知
  controller.addJavaScriptHandler(
      handlerName: 's_pushClearNotification',
      callback: (List<dynamic> arguments) {
        int notificationId = arguments.first;
        JPushUtil.instance.clearNotification(notificationId);
      });
  // 检测通知授权状态是否打开
  controller.addJavaScriptHandler(
      handlerName: 's_pushIsNotificationEnabled',
      callback: (List<dynamic> arguments) async {
        return await JPushUtil.instance.isNotificationEnabled();
      });
  // 跳转至系统设置中应用设置界面
  controller.addJavaScriptHandler(
      handlerName: 's_pushOpenSettingsForNotification',
      callback: (List<dynamic> arguments) {
        JPushUtil.instance.openSettingsForNotification();
      });
}
