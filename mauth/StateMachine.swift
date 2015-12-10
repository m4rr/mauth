//
//  StateMachine.swift
//  mauth
//
//  Created by Marat S. on 07.12.15.
//  Copyright © 2015 m4rr. All rights reserved.
//

import Foundation
import GameplayKit




let startedState = StartedState()
startedState... = self

let tryHTTP🔓State = TryHTTP🔓State()
tryHTTP🔓State... = self

let tryAdState = TryAdState()
tryAdState... = self

let tryHTTPS🔐State = TryHTTPS🔐State()
tryHTTPS🔐State... = self

let successState = SuccessState()
successState... = self

let errorState = ErrorState()
errorState... = self


