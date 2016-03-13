//
//  Car.swift
//  mauth
//
//  Created by Marat S. on 10/10/15.
//  Copyright © 2015 emfo. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration.CaptiveNetwork
//import NetworkExtension

@available(iOS, deprecated=9.0)
class Car {

  func fetchSSIDInfo() -> CFDictionary? {
    if let
      interfaces = CNCopySupportedInterfaces() as? [String],
      interfaceName = interfaces.first,
      info = CNCopyCurrentNetworkInfo(interfaceName as CFStringRef) {
        return info
    }
    return nil
  }

  func lol() {
    if let
      ssidInfo = fetchSSIDInfo() as? [String: AnyObject],
      ssid = ssidInfo["SSID"] as? String {
        print("SSID: \(ssid)")
    } else {
      print("SSID not found")
    }
  }

}
