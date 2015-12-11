//
//  StateMachine.swift
//  mauth
//
//  Created by Marat S. on 07.12.15.
//  Copyright © 2015 m4rr. All rights reserved.
//

import Foundation
import WebKit
import GameplayKit

class Connector: NSObject {

  weak var webView: WKWebView?

  lazy var stateMachine: GKStateMachine = {
    let unitedStates = [
      UnauthorizedState(logic: self),
      TryAdState(logic: self),
      TryHttpState(logic: self),
      TryHttpsState(logic: self),
      SuccessState(logic: self), ErrorState(logic: self)
    ]

    return GKStateMachine(states: unitedStates)
  }()

  init(webView: WKWebView) {
    super.init()

    self.webView = webView
    stateMachine.enterState(UnauthorizedState)
  }

  private let baseUrl🔓 = NSURL(string: "http://ya.ru/")!
  private let baseUrl🔐 = NSURL(string: "https://ya.ru/")!

  private lazy var request🔓: NSURLRequest = NSURLRequest(URL: self.baseUrl🔓, cachePolicy: .ReloadIgnoringCacheData, timeoutInterval: 10)
  private lazy var request🔐: NSURLRequest = NSURLRequest(URL: self.baseUrl🔐, cachePolicy: .ReloadIgnoringCacheData, timeoutInterval: 10)

}


extension Connector: ConnectorStateDelegate {

  func connectorTryHttp() {
    webView?.loadRequest(request🔓)
  }

}


// MARK: - WKNavigationDelegate

extension Connector: WKNavigationDelegate {

  func isSecureBaseUrl(url: NSURL) -> (secure: Bool, base: Bool) {
    let secure = url.scheme == baseUrl🔐.scheme
    let base = url.host == baseUrl🔓.host

    return (secure, base)
  }

  func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    //    addressLabel.text = webView.URL?.absoluteString ?? ""
  }

  /**

   Firstly loaded http://ya.ru that redirected to metro auth page.

   After tap on ad, loads ad-page,
   and since userTappedOnce && webView.URL?.host != ya.ru,
   trying to load https://ya.ru.

   Next guess: massRequest https—http—https.

   */

  func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
    //    --networkActivity

    guard let url = webView.URL else {
      return;
    }

    switch isSecureBaseUrl(url) {
    case (_, false):
      switch stateMachine.currentState {
      case is UnauthorizedState:
        stateMachine.enterState(TryHttpState)

      case is TryAdState:
        stateMachine.enterState(TryAdState)

      default:
        stateMachine.enterState(ErrorState)
      }

    case (false, true):
      stateMachine.enterState(TryHttpsState)

    case (true, true):
      stateMachine.enterState(SuccessState)
    }


//    let maybeLogin = webView.URL?.host?.hasPrefix("login") ?? false
//    //let isYandex = webView.URL?.host == self.baseUrl🔓.host
//    if (!self.userTappedOnce || maybeLogin) {
//      if maybeLogin {
//        if ++self.maybeCount > 1 {
//          dispatch_after_delay_on_main_queue(1) {
//            self.makeDependingRequest(webView.URL)
//          }
//
//          return;
//        }
//      }
//
//      dispatch_after_delay_on_main_queue(4) {
//        self.simulateJS(nil)
//      }
//    } else {
//      dispatch_after_delay_on_main_queue(1) {
//        self.makeDependingRequest(webView.URL)
//      }
//    }

  }

  func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
//    --networkActivity

    stateMachine.enterState(ErrorState)
  }

  //  func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
  //    if userTappedOnce && isBase🔓Url(navigationResponse.response.URL) {
  //      decisionHandler(.Cancel)
  //      //makeDependingRequest()
  //    } else {
  //      decisionHandler(.Allow)
  //    }
  //  }
  
}
