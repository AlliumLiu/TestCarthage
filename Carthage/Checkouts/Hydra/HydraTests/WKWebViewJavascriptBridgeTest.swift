//
//  WKWebViewJavascriptBridgeTest.swift
//  HydraTests
//
//  Created by Chun on 2018/5/4.
//  Copyright © 2018 LLS iOS Team. All rights reserved.
//

import XCTest
import WebKit
@testable import Hydra

class WKWebViewJavascriptBridgeTest: XCTestCase {

  func testRegisterHandler() {
    // Given
    let bridge = WKWebViewJavascriptBridge(webView: WKWebView())

    // When
    bridge.register(handlerName: "test") { (_, _) in
    }

    // Then
    XCTAssert(bridge.messageHandlers["test"] != nil)
  }

  func testRemoveHandler() {
    // Given
    let bridge = WKWebViewJavascriptBridge(webView: WKWebView())

    // When
    bridge.register(handlerName: "test") { (_, _) in
    }

    bridge.remove(handlerName: "test")

    // Then
    XCTAssert(bridge.messageHandlers["test"] == nil)
  }

  func testRemoveAllHandler() {
    // Given
    let bridge = WKWebViewJavascriptBridge(webView: WKWebView())

    // When
    bridge.register(handlerName: "test1") { (_, _) in
    }
    bridge.register(handlerName: "test2") { (_, _) in
    }

    bridge.removeAllHandler()

    // Then
    XCTAssert(bridge.messageHandlers.count == 0)
  }
}
