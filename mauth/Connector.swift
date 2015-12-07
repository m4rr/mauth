//
//  Connector.swift
//  mauth
//
//  Created by Marat S. on 07.12.15.
//  Copyright © 2015 m4rr. All rights reserved.
//

import Foundation

enum ConnectorState: StateMachineDataSource {

  // Ready, Success(NSDictionary), Fail(NSError)
  case Unauthorized, Processing, Authorized

  func shouldTransition(from from: ConnectorState, to: ConnectorState) -> Should<ConnectorState> {
    switch (from, to) {
    case (.Unauthorized, .Processing):
      return .SimulateClick
    case (.Processing, .Authorized):
      return .TryHTTPS
    default:
      return .TryHTTPS
    }
  }
}

class Connector: StateMachineDelegate {

  let machine: StateMachine<Connector>!

  init() {
    machine = StateMachine<Connector>(initialState: .Unauthorized)
    machine.delegate = self
  }

  typealias StateType = ConnectorState

  func didTransition(from from: StateType, to: StateType) {
    switch (from, to){
    case (.Unauthorized, .Processing):
//      updateModel(json)
      ()
    case (.Processing, .Authorized):
//      handleError(error)
      ()
    case (_, .Unauthorized):
//      reloadInterface()
      ()
    default:
      break
    }
  }

}




