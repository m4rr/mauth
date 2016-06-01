//
//  Car.swift
//  mauth
//
//  Created by Marat S. on 10/10/15.
//  Copyright © 2015 emfo. All rights reserved.
//

extension NeatViewController {

  /// ∿ ⌔ 〄
  func checkWiFi(force: Bool = false) {
    if hasWiFi() || force {
      updateLog("∿", NSLocalizedString("Wi-Fi connected", comment: "Wi-Fi connected (log)"))

      NSNotificationCenter.defaultCenter().removeObserver(self)
      reachability.stopNotifier()

      startOperatingWithWiFi()
    } else {
      updateLog("∿", NSLocalizedString("Wi-Fi not connected", comment: "Wi-Fi not connected (log)"))

      NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkWiFi", name: kReachabilityChangedNotification, object: nil)
      reachability.startNotifier()
    }
  }

  private func hasWiFi() -> Bool {
    return reachability.currentReachabilityStatus() == .ReachableViaWiFi
  }

}
