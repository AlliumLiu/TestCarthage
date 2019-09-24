//
//  ViewController.swift
//  HydraDemo
//
//  Created by Chun on 2018/5/3.
//  Copyright © 2018 LLS iOS Team. All rights reserved.
//

import UIKit
import Hydra

enum CustomError: JavascriptError {
  case close

  var errorCode: Int { return 100 }
  var errorMessage: String { return "error" }
}

class ViewController: UIViewController {

  @IBAction func handleOpenWebViewController1() {
    let metaData = HydraWebViewMetaData(appName: "test", appVersion: "1.0", netType: .unknown)
    let webViewController = HydraWebViewController(urlRequest: URLRequest(url: URL(string: "http://bard.fe.thellsapi.com")!), metaData: metaData)
    webViewController.jsBridge.register(handlerName: "closeWebview") { [weak self] _, callback in
      self?.navigationController?.popViewController(animated: true)
      callback(CustomError.close)
    }
    webViewController.loadRequest()
    navigationController?.pushViewController(webViewController, animated: true)
  }

  @IBAction func handleOpenWebViewController2() {
    let webViewController = DemoWebViewController(urlRequest: URLRequest(url: URL(string: "http://bard.fe.thellsapi.com")!))
    navigationController?.pushViewController(webViewController, animated: true)
  }

  @IBAction func handleOpenWebViewController3() {
    let webViewController = DemoCustomWebViewController()
    navigationController?.pushViewController(webViewController, animated: true)
  }
}
