//
//  StateMachine.swift
//  mauth
//
//  Created by Marat S. on 07.12.15.
//  Copyright © 2015 m4rr. All rights reserved.
//

import Foundation

protocol StateMachineDelegate: class {

  typealias StateType: StateMachineDataSource

  func didTransition(from from: StateType, to: StateType)

}

protocol StateMachineDataSource {

  func shouldTransition(from from: Self, to: Self) -> Should<Self>

}

enum Should<T> {

  // Continue, Abort, Redirect(T)
  case SimulateClick, TryHTTP, TryHTTPS

}

class StateMachine<P: StateMachineDelegate> {

  private var _state: P.StateType {
    didSet {
      delegate?.didTransition(from: oldValue, to: _state)
    }
  }

  weak var delegate: P?

  var state: P.StateType {
    get {
      return _state
    }
    set { //Can't be an observer because we need the option to CONDITIONALLY set state
      switch _state.shouldTransition(from: _state, to: newValue) {
//      case .Continue:
//        _state = newValue
//
//      case .Redirect(let redirectState):
//        _state = newValue
//        self.state = redirectState
//
//      case .Abort:
//        break;

      default:
        ()
      }
    }
  }

  init(initialState: P.StateType) {
    _state = initialState //set the primitive to avoid calling the delegate.
  }

  convenience init(initialState: P.StateType, delegate: P) {
    self.init(initialState: initialState)
    self.delegate = delegate
  }

}
