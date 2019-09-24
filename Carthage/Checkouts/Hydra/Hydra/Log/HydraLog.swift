//
//  HydraLog.swift
//  Hydra
//
//  Created by Chun on 2018/8/28.
//  Copyright © 2018 LLS iOS Team. All rights reserved.
//

import Foundation

public class HydraLog {
  public static var `default` = HydraLog { str in
    #if DEBUG
    print(str)
    #endif
  }

  private let output: (String) -> Void

  public init(output: @escaping (String) -> Void) {
    self.output = output
  }

  func log(_ message: String) {
    output("[Hydra]: \(message)")
  }
}
