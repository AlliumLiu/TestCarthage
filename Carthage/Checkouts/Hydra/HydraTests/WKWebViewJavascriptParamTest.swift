//
//  WKWebViewJavascriptParamTest.swift
//  HydraTests
//
//  Created by Chun on 2018/6/5.
//  Copyright © 2018 LLS iOS Team. All rights reserved.
//

import XCTest
@testable import Hydra

class WKWebViewJavascriptParamTest: XCTestCase {

  func testDictionaryDecode() {
    // Given
    let dic: [Int: Any] = [1: 1, 2: "aaa", 3: XCTest()]
    let dic2: [String: Any] = ["a": 1, "b": "aaa", "c": XCTest()]
    let dic3: [String: Any] = ["a": 1, "b": "aaa", "c": 1]

    let array: [Any] = [1, "a", XCTest()]
    let dic4: [String: Any] = ["a": 1, "b": "aaa", "c": array]

    // When
    let param = dic.decodeJavascriptParam()
    let param2 = dic2.decodeJavascriptParam()
    let param3 = dic3.decodeJavascriptParam()
    let param4 = dic4.decodeJavascriptParam()

    // Then
    XCTAssert(param == .null)
    XCTAssert(param2 == .null)
    XCTAssert(param3 != .null)
    XCTAssert(param4 == .null)
  }

  func testArrayDecode() {
    // Given
    let array1: [Any] = [1, "a", XCTest()]
    let array2: [Any] = [1, "a"]

    // When
    let param1 = array1.decodeJavascriptParam()
    let param2 = array2.decodeJavascriptParam()

    // Then
    XCTAssert(param1 == .null)
    XCTAssert(param2 != .null)
  }

  func testDicMap() {
    // Given
    let array: [Any] = [1, "a"]
    let dic: [String: Any] = ["a": 1, "b": "aaa", "c": array]
    let param = dic.decodeJavascriptParam()

    // When
    let jsonObject = javascriptParamMap(param: param)

    // Then
    XCTAssert(JSONSerialization.isValidJSONObject(jsonObject))
  }

  func testArrayMap() {
    // Given
    let tempArray: [Any] = ["a", "1", "1"]
    let dic: [String: Any] = ["a": 1, "b": "aaa", "c": tempArray]
    let array: [Any] = [1, "a", dic]
    let param = array.decodeJavascriptParam()

    // When
    let jsonObject = javascriptParamMap(param: param)

    // Then
    XCTAssert(JSONSerialization.isValidJSONObject(jsonObject))
  }
}
