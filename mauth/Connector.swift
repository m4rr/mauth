//
//  StateMachine.swift
//  mauth
//
//  Created by Marat S. on 07.12.15.
//  Copyright © 2015 m4rr. All rights reserved.
//

import Foundation
import GameplayKit

enum ConnectorNotification: String {

  case connectHttpNotificationName // = "connectHttpNotificationName"

}

class ConnectorLogic {

  private func sendMessage(notification name: ConnectorNotification) {
    NSNotificationCenter.defaultCenter().postNotificationName(name.rawValue, object: nil)
  }

  lazy var stateMachine: GKStateMachine = {
    let unitedStates = [
      UnauthorizedState(),
      TryAdState(),
      TryHttpState(),
      TryHttpsState(),
      SuccessState(), ErrorState()
    ]

    return GKStateMachine(states: unitedStates)
  }()

  init() {
    stateMachine.enterState(UnauthorizedState)
  }

}
