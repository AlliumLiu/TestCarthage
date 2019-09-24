//
//  HydraWebViewMetaData.swift
//  Hydra
//
//  Created by Chun on 2018/5/2.
//  Copyright © 2018 LLS iOS Team. All rights reserved.
//

import Foundation
import UIKit
import CoreTelephony

/// HydraWebViewController 初始化所需要的 Meta 信息，用于构建 userAgent 和 JSBridge 全局对象。
public struct HydraWebViewMetaData {
  /// 当前使用服务的 AppName
  public let appName: String

  /// 当前使用服务的 AppVersion
  public let appVersion: String

  /// 当前使用服务的 JSBridge 全局对象名，默认值为 WKWebViewJavascriptBridge.HydraDefaultMessageName
  public let messageName: String

  /// 当前的网络情况
  public let netType: NetType

  public enum NetType {
    case wifi
    case wwan
    case unknown

    var agentValue: String {
      switch self {
      case .wifi:
        return "WIFI"
      case .wwan:
        return CTTelephonyNetworkInfo().currentRadioAccessTechnology ?? "UNKNOWN"
      case .unknown:
        return "UNKNOWN"
      }
    }
  }

  public init(appName: String,
              appVersion: String,
              netType: NetType,
              messageName: String = WKWebViewJavascriptBridge.HydraDefaultMessageName) {
    self.appName = appName
    self.appVersion = appVersion
    self.netType = netType
    self.messageName = messageName
  }

  /**
   $appName/$appVersion ($model;$osName $osVersion;) NetType/$netType liulishuo
   */
  public func generateUserAgent() -> String {
    return "\(appName)/\(appVersion) (\(UIDevice.current.model);\(UIDevice.current.systemName) \(mapSystemVerison());) NetType/\(netType.agentValue) liulishuo"
  }

  private func mapSystemVerison() -> String {
    return UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
  }
}
