//
//  LogManager.swift
//  mauth
//
//  Created by Marat S. on 13/03/16.
//  Copyright © 2016 m4rr. All rights reserved.
//

import Foundation
import WebKit

class LogManager {

  static var shared: LogManager!

  private weak var webView: WKWebView?

  init(webView: WKWebView) {
    self.webView = webView

    LogManager.shared = self
  }

  func logSourceCode(completion: (host: String, text: String) -> Void) {
    guard let webView = webView, url = webView.URL, host = url.host else {
      return
    }

    let querySelector = "document.getElementsByTagName('html')[0].outerHTML"

    webView.evaluateJavaScript(querySelector) { result, error in
      if let html = result as? String {
        let sourceCode = url.absoluteString + "\n\n" + html

        completion(host: host, text: sourceCode)
      }
    }
  }

}
