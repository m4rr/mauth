//
//  WaitForWiFiOperation.swift
//  mauth
//
//  Created by Marat S. on 15/03/16.
//  Copyright © 2016 m4rr. All rights reserved.
//

import Foundation

class WaitWiFiOperation: Operation {

  override init() {
    super.init()

    //addCondition(ReachabilityCondition(host: NSURL(string: "http://1.1.1.1")!))
    //addCondition(ReachabilityCondition(host: NSURL(string: "https://m4rr.ru")!))
  }

}