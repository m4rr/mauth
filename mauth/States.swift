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

class StartedState: GKState {

  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == TryHttpState.self
  }

  override func didEnterWithPreviousState(previousState: GKState?) {

  }

  override func updateWithDeltaTime(seconds: NSTimeInterval) {

  }

  override func willExitWithNextState(nextState: GKState) {

  }

}

class TryHttpState: GKState {
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == TryAdState.self || stateClass == TryHttpsState.self
  }
}

class TryAdState: GKState {
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == TryHttpState.self
  }
}

class TryHttpsState: GKState {
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == SuccessState.self || stateClass == ErrorState.self
  }
}

class SuccessState: GKState {
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == StartedState.self
  }
}

class ErrorState: GKState {
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == StartedState.self
  }
}


