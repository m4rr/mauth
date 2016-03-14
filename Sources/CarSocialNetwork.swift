//
//  Car.swift
//  mauth
//
//  Created by Marat S. on 10/10/15.
//  Copyright © 2015 emfo. All rights reserved.
//

import Foundation

extension NeatViewController {

  /// ∿ ⌔ 〄
  func checkWiFi() {
    if hasWiFi() {
      updateLog("∿", "Wi-Fi reachable")

      NSNotificationCenter.defaultCenter().removeObserver(self)
      reachability.stopNotifier()

      startOperatingWithWiFi()
    } else {
      updateLog("∿", "Wi-Fi not reachable, waiting...")

      NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkWiFi", name: kReachabilityChangedNotification, object: nil)
      reachability.startNotifier()
    }
  }

  private func hasWiFi() -> Bool {
    return reachability.currentReachabilityStatus() == .ReachableViaWiFi
  }

}
