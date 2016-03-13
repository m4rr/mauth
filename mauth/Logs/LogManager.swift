//
//  LogManager.swift
//  mauth
//
//  Created by Marat S. on 13/03/16.
//  Copyright © 2016 m4rr. All rights reserved.
//

import Foundation
import WebKit

let logSourceCodeNotification = "logSourceCodeNotification"
private let loggedKey = "logged"

class LogManager {

  static var shared: LogManager!

  private weak var webView: WKWebView!

  var log: [(String, AnyObject)] {
    return Array(NSUserDefaults.standardUserDefaults().dictionaryForKey(loggedKey) ?? [:])
  }

  init(webView: WKWebView) {
    self.webView = webView

    LogManager.shared = self

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "logSourceCode", name: logSourceCodeNotification, object: nil)
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  private var logged: [String: AnyObject] {
    get {
      return NSUserDefaults.standardUserDefaults().dictionaryForKey(loggedKey) ?? [:]
    }
    set {
      NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: loggedKey)
    }
  }

  private func logSourceCode() {
    guard let url = webView.URL, host = url.host else {
      return
    }

    let querySelector = "document.getElementsByTagName('html')[0].outerHTML"

    webView.evaluateJavaScript(querySelector) { result, error in
      if let html = result as? String {
        self.logged[host] = url.absoluteString + "\n\n" + html
      }
    }
  }

}
