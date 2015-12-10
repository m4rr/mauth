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

/*

  - запуск
  - попытка открыть яндекс
  - попытка кликнуть на рекламу
  - попытка открыть секьюрный яндекс
  - успех
  - ошибка
  
  + если открылась реклама
  + если яндекс
  + когда загрузилось

*/
}

class SimpleConnector {

  enum Стейты {
    case запуск,
    попытка_открыть_яндекс,
    попытка_кликнуть_на_рекламу,
    попытка_открыть_секьюрный_яндекс,
    успех,
    ошибка
  }

  enum Транзишены {
    case если_открылась_реклама,
    если_яндекс,
    когда_загрузилось
  }

}
