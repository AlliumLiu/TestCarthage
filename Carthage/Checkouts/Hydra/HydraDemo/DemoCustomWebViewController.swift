//
//  DemoCustomWebViewController.swift
//  HydraDemo
//
//  Created by Chun on 2018/5/4.
//  Copyright © 2018 LLS iOS Team. All rights reserved.
//

import UIKit
import WebKit
import Hydra

class DemoCustomWebViewController: UIViewController {

  deinit {
    print("DemoCustomWebViewController deinit")
  }

  var jsBridge: WKWebViewJavascriptBridge!
  var webView: WKWebView!

  override func viewDidLoad() {
    super.viewDidLoad()

    loadWebView()
    handleJSEvent()
    webView.load(URLRequest(url: URL(string: "http://bard.fe.thellsapi.com")!))
  }

  private func loadWebView() {
    webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
    jsBridge = WKWebViewJavascriptBridge(webView: webView)

    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.scrollView.showsHorizontalScrollIndicator = false
    webView.scrollView.showsVerticalScrollIndicator = false
    view.addSubview(webView)

    NSLayoutConstraint.activate([
      webView.topAnchor.constraint(equalTo: view.topAnchor),
      webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      webView.leftAnchor.constraint(equalTo: view.leftAnchor),
      webView.rightAnchor.constraint(equalTo: view.rightAnchor)
    ])
  }

  private func handleJSEvent() {
    jsBridge.register(handlerName: "closeWebview") { [weak self] (_, callback) in
      self?.navigationController?.popViewController(animated: true)
      callback(nil)
    }
  }
}
