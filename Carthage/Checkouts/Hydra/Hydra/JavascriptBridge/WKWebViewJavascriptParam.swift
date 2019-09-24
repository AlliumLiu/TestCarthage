//
//  WKWebViewJavascriptParam.swift
//  Hydra
//
//  Created by Chun on 2018/5/3.
//  Copyright © 2018 LLS iOS Team. All rights reserved.
//

import Foundation

/// WKWebView Javascript 支持的类型协议
public protocol JavascriptParamType {
  func decodeJavascriptParam() -> JavascriptParam
}

extension Int: JavascriptParamType {
  public func decodeJavascriptParam() -> JavascriptParam {
    return .init(self)
  }
}

extension Float: JavascriptParamType {
  public func decodeJavascriptParam() -> JavascriptParam {
    return .init(self)
  }
}

extension Double: JavascriptParamType {
  public func decodeJavascriptParam() -> JavascriptParam {
    return .init(self)
  }
}

extension String: JavascriptParamType {
  public func decodeJavascriptParam() -> JavascriptParam {
    return .init(self)
  }
}

extension Bool: JavascriptParamType {
  public func decodeJavascriptParam() -> JavascriptParam {
    return .init(self)
  }
}

extension Dictionary: JavascriptParamType {
  /// 当 Dictionary 为无效的 JSONObject 时，JavascriptParam 返回的值为 .null
  ///
  /// - Returns: JavascriptParam
  public func decodeJavascriptParam() -> JavascriptParam {
    if JSONSerialization.isValidJSONObject(self) {
      return JavascriptParam(self)
    } else {
      return JavascriptParam.null
    }
  }
}

extension Array: JavascriptParamType {
  /// 当 Array 为无效的 JSONObject 时，JavascriptParam 返回的值为 .null
  ///
  /// - Returns: JavascriptParam
  public func decodeJavascriptParam() -> JavascriptParam {
    if JSONSerialization.isValidJSONObject(self) {
      return JavascriptParam(self)
    } else {
      return JavascriptParam.null
    }
  }
}

/// WKWebView Javascript 支持的类型
public enum JavascriptParam: Equatable {
  case null
  case int(Int)
  case float(Float)
  case double(Double)
  case string(String)
  case bool(Bool)
  case array([JavascriptParam])
  case object(rawData: [String: JavascriptParam], isErrorObject: Bool)
  
  init(_ value: Any) {
    switch value {
    case let v as [Any]:
      self = .array(v.map(JavascriptParam.init))
    case let v as [String: Any]:
      self = .object(rawData: v.map(JavascriptParam.init), isErrorObject: false)
    case let v as String:
      self = .string(v)
    case let v as Int:
      self = .int(v)
    case let v as Float:
      self = .float(v)
    case let v as Double:
      self = .double(v)
    case let v as Bool:
      self = .bool(v)
    case let v as JavascriptError:
      self = .object(rawData: v.javascriptErrorParameter.map(JavascriptParam.init), isErrorObject: true)
    default:
      self = .null
    }
  }
}

/// Hydra 模块在内部处理 JS Bridge 调用时, 定义的 Error 类型
/// 当你需要传递 Error 到 WKWebViewJavascriptBridge 时，需要让 Error 支持 `JavascriptError`
public protocol JavascriptError: Error, JavascriptParamType {
  var errorCode: Int { get }
  var errorMessage: String { get }
}

extension JavascriptError {
  var javascriptErrorParameter: [String: Any] {
    return ["code": errorCode, "message": errorMessage]
  }
  
  public func decodeJavascriptParam() -> JavascriptParam {
    return .init(self)
  }
}

// MARK: - Internal Error

enum InternalError: JavascriptError {
  case paramTypeInvalid(Any)
  
  var errorCode: Int {
    switch self {
    case .paramTypeInvalid:
      return -9999
    }
  }
  
  var errorMessage: String {
    switch self {
    case .paramTypeInvalid:
      return "param Type not invalid."
    }
  }
}

// MARK: - Internal Help

extension Dictionary {
  func map<T>(_ f: (Value) -> T) -> [Key: T] {
    var accum = [Key: T](minimumCapacity: self.count)
    for (key, value) in self {
      accum[key] = f(value)
    }
    return accum
  }
}

func map(array: [JavascriptParam]) -> [Any] {
  return array.map(javascriptParamMap)
}

func map(object: [String: JavascriptParam]) -> [String: Any] {
  return object.map(javascriptParamMap)
}

func javascriptParamMap(param: JavascriptParam) -> Any {
  switch param {
  case .array(let array):
    return map(array: array)
  case .bool(let bool):
    return bool
  case .double(let double):
    return double
  case .float(let float):
    return float
  case .int(let int):
    return int
  case .null:
    return "null"
  case .string(let string):
    return string
  case .object(let rawData, _):
    return map(object: rawData)
  }
}
