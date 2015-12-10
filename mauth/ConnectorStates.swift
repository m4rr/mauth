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

class ConnectorState: GKState {

//  unowned var logic: ConnectorLogic?

}

class UnauthorizedState: ConnectorState {

  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == TryHttpState.self
  }

  override func didEnterWithPreviousState(previousState: GKState?) {

  }

  override func willExitWithNextState(nextState: GKState) {

  }

}

class TryAdState: ConnectorState {

  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == TryHttpState.self
  }

  override func didEnterWithPreviousState(previousState: GKState?) {
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
    // webview.load HTTP
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
    if previousState is TryHttpState {
      // webview.load HTTPS
    }
  }

}

class SuccessState: ConnectorState {

  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == UnauthorizedState.self
  }

}

class ErrorState: ConnectorState {

  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == UnauthorizedState.self
  }
  
}
