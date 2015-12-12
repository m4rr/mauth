//
//  States.swift
//  mauth
//
//  Created by Marat S. on 10.12.15.
//  Copyright © 2015 m4rr. All rights reserved.
//

import Foundation
import GameplayKit

/**

 ### States:
 - запуск
 - попытка открыть яндекс
 - попытка кликнуть на рекламу
 - попытка открыть секьюрный яндекс
 - успех
 - ошибка

 ### Transitions:
 + если открылась реклама
 + если яндекс
 + когда загрузилось

 */

protocol ConnectorStateDelegate: class {

  func connectorTryHttp()

  func connectorTryHttps()

}

class ConnectorState: GKState {

  weak var logic: ConnectorStateDelegate?

  init(logic: ConnectorStateDelegate) {
    super.init()

    self.logic = logic
  }

  override func didEnterWithPreviousState(previousState: GKState?) {
    print("Entered " + "\(self.dynamicType)")
  }

}

class UnauthorizedState: ConnectorState {

  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == TryAdState.self
      || stateClass == TryHttpState.self
  }

  override func didEnterWithPreviousState(previousState: GKState?) {
    super.didEnterWithPreviousState(nil)

    stateMachine?.enterState(TryHttpState)

  }

  override func willExitWithNextState(nextState: GKState) {
    //
  }

}

class TryAdState: ConnectorState {

  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == TryHttpState.self
  }

  override func didEnterWithPreviousState(previousState: GKState?) {
    super.didEnterWithPreviousState(nil)

    // clickJS

    let opQueue = NSOperationQueue.mainQueue()

    opQueue.addOperationWithBlock { () -> Void in
      dispatch_after_delay_on_main_queue(2) {
        // simulateJS
      }
    }

  }

}

class TryHttpState: ConnectorState {

  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == TryAdState.self
      || stateClass == TryHttpsState.self
      || stateClass == ErrorState.self
  }

  override func didEnterWithPreviousState(previousState: GKState?) {
    super.didEnterWithPreviousState(nil)

    // webview.load HTTP
    logic?.connectorTryHttp()
  }

  override func willExitWithNextState(nextState: GKState) {
    //
  }

}

class TryHttpsState: ConnectorState {

  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == SuccessState.self
      || stateClass == ErrorState.self
  }

  override func didEnterWithPreviousState(previousState: GKState?) {
    super.didEnterWithPreviousState(nil)

    if previousState is TryHttpState {
      // webview.load HTTPS

      logic?.connectorTryHttps()
    }
  }

}

class SuccessState: ConnectorState {

  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == UnauthorizedState.self
  }

  override func didEnterWithPreviousState(previousState: GKState?) {
    super.didEnterWithPreviousState(nil)
  }

}

class ErrorState: ConnectorState {

  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == UnauthorizedState.self
  }

  override func didEnterWithPreviousState(previousState: GKState?) {
    super.didEnterWithPreviousState(nil)
  }

}
