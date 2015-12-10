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

@available(iOS 9.0, *)
class StartedState: GKState {

  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == TryHTTP🔓State.self
  }

  override func didEnterWithPreviousState(previousState: GKState?) {

  }

  override func updateWithDeltaTime(seconds: NSTimeInterval) {

  }

  override func willExitWithNextState(nextState: GKState) {

  }

}

@available(iOS 9.0, *)
class TryHTTP🔓State: GKState {
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == TryAdState.self || stateClass == TryHTTPS🔐State.self
  }
}

@available(iOS 9.0, *)
class TryAdState: GKState {
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == TryHTTP🔓State.self
  }
}

@available(iOS 9.0, *)
class TryHTTPS🔐State: GKState {
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == SuccessState.self || stateClass == ErrorState.self
  }
}

@available(iOS 9.0, *)
class SuccessState: GKState {
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == StartedState.self
  }
}

@available(iOS 9.0, *)
class ErrorState: GKState {
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == StartedState.self
  }
}


