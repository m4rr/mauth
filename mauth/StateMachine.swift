//
//  StateMachine.swift
//  mauth
//
//  Created by Marat S. on 07.12.15.
//  Copyright © 2015 m4rr. All rights reserved.
//

import Foundation
import GameplayKit

class Connector {

  lazy var unitedStates: [GKState] = [StartedState(), TryHttpState(), TryAdState(), TryHttpsState(), SuccessState(), ErrorState()]

  lazy var stateMachine: GKStateMachine = {
    return GKStateMachine(states: self.unitedStates)
  }()

  init() {

    stateMachine.enterState(StartedState)

  }

}
