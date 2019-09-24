//
//  Test.swift
//  TestCarthage
//
//  Created by cong liu on 2019/9/24.
//  Copyright © 2019 cong liu. All rights reserved.
//

import Foundation
import UIKit
import Hydra

public class Test: NSObject {
  public static func printTest() {
    print("test test ....")
  }

  public static func printHydra() {
    print(HydraVersionNumber)
  }
}


public class TestView: UIView {
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = .red
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func printFrame() {
    print(frame)
  }
  
  public func printHydra() {
    print(HydraVersionNumber)
  }

}
