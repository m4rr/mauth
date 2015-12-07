//
//  SimpleStateMachine.swift
//  mauth
//
//  Created by Marat S. on 07.12.15.
//  Copyright © 2015 m4rr. All rights reserved.
//

import Foundation

enum SimpleStateType: Int {
  case Unauthorized, Processing, Authorized
}

protocol SimpleStateMachineProtocol {

  func simulateClick()

  func tryHTTP()

  func tryHTTPS()

}

extension SimpleStateMachineProtocol {

  func shouldTransition(from from: SimpleStateType, to: SimpleStateType) -> Bool {
    switch (from, to) {
    case (.Unauthorized, .Processing), (.Processing, .Authorized), (.Authorized, .Unauthorized):
      return true
    default:
      return false
    }
  }

  func didTransition(from from: SimpleStateType, to: SimpleStateType) -> Void {
    switch (from, to) {
    case (.Unauthorized, .Processing):
      simulateClick()
    case (.Processing, .Authorized):
      tryHTTPS()
    default:
      tryHTTP()
    }
  }

}

class SimpleConnector: SimpleStateMachineProtocol {

  func simulateClick() {

  }

  func tryHTTP() {

  }

  func tryHTTPS() {

  }

}
