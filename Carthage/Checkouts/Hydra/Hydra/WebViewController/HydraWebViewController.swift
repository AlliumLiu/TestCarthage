//
//  HydraWebViewController.swift
//  Hydra
//
//  Created by Chun on 2018/5/2.
//  Copyright © 2018 LLS iOS Team. All rights reserved.
//

import UIKit
import WebKit

open class HydraWebViewController: UIViewController {
  // MARK: - Public

  /// 当前 WebViewController 中的 webView
  public private(set) var webView: WKWebView!

  /// 当前 WebViewController 中使用的 jsBridge
  public var jsBridge: WKWebViewJavascriptBridge! {
    didSet {
      jsBridge.webView = webView
    }
  }

  /// 当前 WebViewController 中初始化的 urlRequest
  public let originalURLRequest: URLRequest

  /// 当前 WebViewController 中初始化的 metaData
  public let metaData: HydraWebViewMetaData

  /// 当前 WebView layout 时，会根据这个值去改变 WebView 和它 SuperView 的边距。默认值为 `.zero`
  open var specialWebViewAreaInsets: UIEdgeInsets {
    return .zero
  }

  /// 初始化 WebViewController
  ///
  /// - Parameters:
  ///   - urlRequest: WebViewController 需要 load 的 request
  ///   - metaData: WebViewController 初始化需要的 Meta 信息
  public init(urlRequest: URLRequest, metaData: HydraWebViewMetaData) {
    self.originalURLRequest = urlRequest
    self.metaData = metaData
    super.init(nibName: nil, bundle: nil)

    HydraLog.default.log("HydraWebViewController \(self) init with urlRequest: \(originalURLRequest), and userAgent: \(metaData.generateUserAgent())")

    let webViewConfig = WKWebViewConfiguration()
    webViewConfig.processPool = HydraWebViewController.processPool
    webViewConfig.userContentController = WKUserContentController()
    webViewConfig.allowsInlineMediaPlayback = true
    webViewConfig.requiresUserActionForMediaPlayback = false

    webView = WKWebView(frame: .zero, configuration: webViewConfig)
    jsBridge = WKWebViewJavascriptBridge(webView: webView, messsageName: metaData.messageName)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    jsBridge.removeAllHandler()
    
    _ = URL(string: "about:blank")
      .map { URLRequest(url: $0) }
      .map { webView.load($0) }
    
    HydraLog.default.log("HydraWebViewController \(self) deinit")
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    loadWebView()
    configWebViewAgent()
  }

  /// 加载初始化赋值的请求 `originalURLRequest`
  public func loadRequest() {
    webView.load(originalURLRequest)
  }

  // MARK: - private

  private static let processPool = WKProcessPool()

  private func loadWebView() {
    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.scrollView.showsHorizontalScrollIndicator = false
    webView.scrollView.showsVerticalScrollIndicator = false
    view.addSubview(webView)

    NSLayoutConstraint.activate([
      webView.topAnchor.constraint(equalTo: view.topAnchor, constant: specialWebViewAreaInsets.top),
      webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: specialWebViewAreaInsets.bottom),
      webView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: specialWebViewAreaInsets.left),
      webView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: specialWebViewAreaInsets.right)
    ])
  }

  private func configWebViewAgent() {
    webView.customUserAgent = metaData.generateUserAgent()
  }
}
