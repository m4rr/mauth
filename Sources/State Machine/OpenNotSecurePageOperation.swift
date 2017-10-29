//
//  OpenNotSecurePageOperation.swift
//  mauth
//
//  Created by Marat S. on 21/02/16.
//  Copyright © 2016 m4rr. All rights reserved.
//

import Foundation
import WebKit
import PSOperations

 let baseUrl🔓 = URL(string: "http://192.162.1.1/")! // unsecure but trusted website
 let baseUrl🔐 = URL(string: "https://ya.ru/")! // secure copy
private var request🔓 = URLRequest(url: baseUrl🔓, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
private var request🔐 = URLRequest(url: baseUrl🔐, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)

protocol ConnectorDelegate: class {

  func updateLog(_ prefix: String, _ text: String)

  func connectorDidStartLoad(url: String)

  func connectorDidEndLoad(title: String, url: URL?)

  func connectorProgress(old: Float, new: Float)

  func connectorDidGetSecurePageMatchHost()
  
}

//class OpenSecurePageOperation: OpenPageOperation {
//
//}

//class OpenNotSecurePageOperation: OpenPageOperation {
//
//}

extension NeatViewController {

  func isSecureBaseUrl(url: URL) -> (secure: Bool, base: Bool) {
    let secure = webView.hasOnlySecureContent // url.scheme == baseUrl🔐.scheme
    let base = url.host == (secure ? baseUrl🔐 : baseUrl🔓).host

    return (secure, base)
  }

  func connectorTryHttp() {
    webView.load(request🔓)
  }

  func connectorTryHttps() {
    webView.load(request🔐)
  }

}

// MARK: WKNavigationDelegate

extension NeatViewController: WKNavigationDelegate {

  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    delegate?.connectorDidStartLoad(url: webView.url?.absoluteString ?? "")
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    delegate?.connectorDidEndLoad(title: webView.title ?? "title", url: webView.url)

    if let url = webView.url, url.host?.contains("wi-fi") == true || url.host == baseUrl🔓.host {
      // wait
    } else {
      state.next()
    }

  }

  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    delegate?.updateLog("didFailNavigation", error.localizedDescription)

    webView.goBack()
  }

  func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
    delegate?.updateLog("didReceiveServerRedirect", webView.url?.absoluteString ?? "")
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard let keyPath = keyPath, let change = change else {
      return;
    }

    switch keyPath {
    case "estimatedProgress":
      if let new = change[.newKey] as? Float, let old = change[.oldKey] as? Float {
        DispatchQueue.main.async {
          self.delegate?.connectorProgress(old: old, new: new)
          //self.progressBar.setProgress(new, animated: old < new)
        }
      }

    default:
      ()
    }
  }

}

// MARK: JavaScript

extension NeatViewController {

  func simulateJS() {
    let aClick = [
      "document.querySelector('iframe#branding').contentDocument.body.querySelector('#root #content a').click();",
      "document.querySelector('iframe#branding').contentDocument.body.querySelector('#banner-metro').click();",
    ]

    aClick.forEach { query in
      webView.evaluateJavaScript(query, completionHandler: { (k, e) in

      })
      webView.evaluateJavaScript(query) { result, error in
        if let error = error { //  WKError.javaScriptExceptionOccurred {
          // clicking by defunct selectors guaranteed produce errors
          self.delegate?.updateLog("js click err", "\(error.localizedDescription)")
        } else {
          self.delegate?.updateLog("js click", "res")
        }
      }
    }
  }

}

