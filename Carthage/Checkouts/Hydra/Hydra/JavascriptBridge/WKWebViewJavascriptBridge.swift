//
//  WKWebViewJavascriptBridge.swift
//  Hydra
//
//  Created by Chun on 2018/5/3.
//  Copyright © 2018 LLS iOS Team. All rights reserved.
//

import Foundation
import WebKit

/// WKWebViewJavascriptBridge 用于处理和前端 JS 之间的交互，完善了其中协议部分。
/// 关于目前的交互协议，可以参考如下: `https://git.llsapp.com/docs/jsbridge-api-doc`
final public class WKWebViewJavascriptBridge: NSObject {
  /// WKWebViewJavascriptBridge 定义的 Callback 类型, 当 Handler 方法调用成功时，在没有参数传递的情况下，参数应置为 nil。当 Handler 调用失败时，应当传递 `JavascriptError` 类型。
  /// - Parameters:
  ///   - param: 根据接口定义确定是否需要赋值
  public typealias Callback = (_ param: JavascriptParamType?) -> Void

  /// WKWebViewJavascriptBridge 定义的 Handler 类型
  public typealias Handler = (_ parameters: [String: Any]?, _ callback: @escaping Callback) -> Void

  /// 前端团队目前默认支持的 iOS JS 全局对象 Name，值为 `iOSApi`
  public static let HydraDefaultMessageName = "iOSApi"

  /// 需要支持该套协议交互的 WebView，WKWebViewJavascriptBridge 内部 weak 引用
  public weak var webView: WKWebView?

  /// 初始化 WKWebViewJavascriptBridge
  ///
  /// - Parameters:
  ///   - webView: 需要支持该套协议交互的 WebView，WKWebViewJavascriptBridge 内部 weak 引用
  ///   - messsageName: handle JS 全局对象名称。默认值为 `HydraDefaultMessageName`
  public init(webView: WKWebView?, messsageName: String = HydraDefaultMessageName) {
    self.messageName = messsageName
    self.webView = webView
    super.init()

    addScriptMessageHandlers()
  }
  
  deinit {
    removeScriptMessageHandlers()
  }

  /// 注册一个前端事件
  ///
  /// - Parameters:
  ///   - handlerName: 前端事件名称, 大小写敏感
  ///   - handler: 对事件的处理，成功或者失败后，应该调用 Handler 中的 callback
  public func register(handlerName: String, handler: @escaping Handler) {
    if let handler = messageHandlers[handlerName] {
      fatalError("\(handlerName) is registered, the handler is \(String(describing: handler))")
    } else {
      messageHandlers[handlerName] = handler
    }
  }

  /// 移除一个前端事件
  ///
  /// - Parameter handlerName: 前端事件名称, 大小写敏感
  /// - Returns: 当前移除的 Handler 对象
  @discardableResult
  public func remove(handlerName: String) -> Handler? {
    return messageHandlers.removeValue(forKey: handlerName)
  }

  /// 移除所有已注册的前端事件
  public func removeAllHandler() {
    messageHandlers.removeAll()
  }

  /// 在当前 Bridge 中调用前端的方法
  ///
  /// - Parameters:
  ///   - handlerName: 前端定义的方法名
  ///   - param: 根据接口定义确定是否需要赋值, 默认为 nil，当为 Error 时应当传递 `JavascriptError` 类型
  public func call(handlerName: String, param: JavascriptParamType? = nil) {
    let javascriptString = getFullJavascriptFunction(handlerName, param: param?.decodeJavascriptParam() ?? JavascriptParam.null)
    evaluateJavascript(javascriptString)
  }

  // MARK: - Internal

  var messageHandlers = [String: Handler]()

  let messageName: String

  func addScriptMessageHandlers() {
    webView?.configuration.userContentController.add(LeakAvoider(delegate: self), name: messageName)
  }

  func removeScriptMessageHandlers() {
    webView?.configuration.userContentController.removeScriptMessageHandler(forName: messageName)
  }
}

extension WKWebViewJavascriptBridge: WKScriptMessageHandler {
  public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    HydraLog.default.log("WKScriptMessageHandler receive message: \(message), message.name: \(message.name), message.body: \(message.body)")
    handleScriptMessage(message)
  }
}

extension WKWebViewJavascriptBridge {
  /**
   window.webkit.messageHandlers.iOSApi.postMessage({
     eventName: {apiName}
     args: [
       params,
       callback
     ]
   })
   
   其中 params 是一个 jsonString，使用的时候需要转换成 dictionary
   */
  private func handleScriptMessage(_ message: WKScriptMessage) {
    if messageName == message.name {
      if let bodyDictionary = message.body as? [String: Any], let eventName = bodyDictionary["eventName"] as? String, let args = bodyDictionary["args"] as? [Any], args.count == 2, let callback = args[1] as? String {
        let parameters = convertAnyToJSONObject(args[0]).flatMap { $0 as? [String: Any] }
        if let handler = messageHandlers[eventName] {
          handler(parameters) { param in
            self.call(handlerName: callback, param: param)
          }
        }
      }
    }
  }

  private func getFullJavascriptFunction(_ funcName: String, param: JavascriptParam) -> String {
    switch param {
    case .bool(let boolValue):
      if boolValue {
        return "\(funcName)(null, true)"
      } else {
        return "\(funcName)(null, false)"
      }
    case .int(let intValue):
      return "\(funcName)(null, \(intValue))"
    case .double(let doubleValue):
      return "\(funcName)(null, \(doubleValue))"
    case .float(let floatValue):
      return "\(funcName)(null, \(floatValue))"
    case .string(let string):
      return "\(funcName)(null, '\(string)')"
    case .array(let array):
      if let parameter = convertAnyToJSONString(map(array: array)) {
        return "\(funcName)(null, \(parameter))"
      } else {
        return "\(funcName)(null, null)"
      }
    case .object(let rawData, let isErrorObject):
      if let parameter = convertAnyToJSONString(map(object: rawData)) {
        if isErrorObject {
          return "\(funcName)(\(parameter))"
        } else {
          return "\(funcName)(null, \(parameter))"
        }
      } else {
        return "\(funcName)(null, null)"
      }
    case .null:
      return "\(funcName)(null)"
    }
  }

  private func evaluateJavascript(_ javaScriptString: String) {
    HydraLog.default.log("evaluateJavascript \(javaScriptString)")
    let evaluateJavascriptString = "try { \(javaScriptString) } catch (e) { throw e }"
    webView?.evaluateJavaScript(evaluateJavascriptString, completionHandler: { (response, error) in
      HydraLog.default.log("evaluateJavascript \(javaScriptString) finished. And response: \(String(describing: response)), error: \(String(describing: error))")
    })
  }
}

private func convertAnyToJSONString(_ obj: Any?) -> String? {
  return obj
    .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: .prettyPrinted) }
    .flatMap { String(data: $0, encoding: .utf8) }
}

private func convertAnyToJSONObject(_ obj: Any?) -> Any? {
  return obj
    .flatMap { $0 as? String }
    .flatMap { $0.data(using: .utf8) }
    .flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) }
}

private class LeakAvoider: NSObject, WKScriptMessageHandler {
  weak var delegate: WKScriptMessageHandler?
  
  init(delegate: WKScriptMessageHandler) {
    self.delegate = delegate
    super.init()
  }
  
  func userContentController(_ userContentController: WKUserContentController,
                             didReceive message: WKScriptMessage) {
    delegate?.userContentController(userContentController, didReceive: message)
  }
}
