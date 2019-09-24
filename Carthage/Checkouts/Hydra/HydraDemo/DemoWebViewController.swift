//
//  DemoWebViewController.swift
//  HydraDemo
//
//  Created by Chun on 2018/5/4.
//  Copyright © 2018 LLS iOS Team. All rights reserved.
//

import Foundation
import Hydra

class DemoWebViewController: HydraWebViewController {
 
  override var specialWebViewAreaInsets: UIEdgeInsets {
    return UIEdgeInsets(top: 100, left: 10, bottom: -10, right: -10)
  }

  init(urlRequest: URLRequest) {
    let metaData = HydraWebViewMetaData(appName: "test", appVersion: "1.0", netType: .unknown)
    super.init(urlRequest: urlRequest, metaData: metaData)

    NotificationCenter.default.addObserver(self, selector: #selector(handleOnActive), name: UIApplication.didBecomeActiveNotification, object: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    print("DemoWebViewController Deinit")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    registerHandler()
    loadRequest()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    handleOnActive()
  }

  private func registerHandler() {
    jsBridge.register(handlerName: "closeWebview") { [weak self] (params, callback) in
      self?.jsBridgeCloseWebview(parameters: params, callback)
    }

    jsBridge.register(handlerName: "on.active") { [weak self] (params, callback) in
      self?.onActiveListernr = params?["listener"] as? String
      callback(nil)
    }

    jsBridge.call(handlerName: "test1", param: nil)
    jsBridge.call(handlerName: "test2", param: ["a", "b"])
    jsBridge.call(handlerName: "test3", param: ["a": 1, "b": "c"])

    let array: [Any] = [1, "a"]
    let dic: [String: Any] = ["a": 1, "b": "aaa", "c": array]
    jsBridge.call(handlerName: "test4", param: dic)

    let tempArray: [Any] = ["a", "1", "1"]
    let dic2: [String: Any] = ["a": 1, "b": "aaa", "c": tempArray]
    let array2: [Any] = [1, "a", dic2]
    jsBridge.call(handlerName: "test5", param: array2)
  }

  private var onActiveListernr: String?
  @objc private func handleOnActive() {
    onActiveListernr.map { jsBridge.call(handlerName: $0) }
  }

  private func jsBridgeCloseWebview(parameters: [String: Any]?, _ callback: WKWebViewJavascriptBridge.Callback) {
    navigationController?.popViewController(animated: true)
    callback(nil)
  }
}
