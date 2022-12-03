import 'package:flutter_browser/utils/js_channel/js_handler_ble.dart';
import 'package:flutter_browser/utils/js_channel/js_handler_push.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

///
/// JsChannelUtil
///
/// Created by Jack Zhang on 2022/11/26 .
///
class JsHandler {
  void addJavaScriptHandlers(InAppWebViewController controller) {
    // 注册推送相关JS Handler
    registerJsHandlerPush(controller);
    // 注册蓝牙相关JS Handler
    registerJsHandlerBle(controller);
  }
}
