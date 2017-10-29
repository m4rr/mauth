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

private let baseUrl🔓 = URL(string: "http://wtfismyip.com/text")! // unsecure but trusted website
private let baseUrl🔐 = URL(string: "https://wtfismyip.com/text")! // secure copy
private var request🔓 = URLRequest(url: baseUrl🔓, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
private var request🔐 = URLRequest(url: baseUrl🔐, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)

protocol ConnectorDelegate: class {

  func updateLog(_ prefix: String, _ text: String)

  func connectorDidStartLoad(url: String)

  func connectorDidEndLoad(title: String, url: String)

  func connectorProgress(old: Float, new: Float)

  func connectorDidGetSecurePageMatchHost()
  
}

//class OpenSecurePageOperation: OpenPageOperation {
//
//}

//class OpenNotSecurePageOperation: OpenPageOperation {
//
//}

final class OpenPageOperation: PSOperations.Operation {

  private weak var webView: WKWebView!
  private weak var delegate: ConnectorDelegate?

  init(webView: WKWebView! = nil, delegate: ConnectorDelegate) {
    assert(webView != nil, "webView should not be nil")

    self.delegate = delegate
    self.webView = webView

    super.init()

    addCondition(MutuallyExclusive<OpenPageOperation>())
  }

  private func isSecureBaseUrl(url: URL) -> (secure: Bool, base: Bool) {
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

  func checkWillRefresh(completion: @escaping (_ willRefresh: Bool) -> Void) {
    webView.evaluateJavaScript("document.getElementsByTagName('html')[0].outerHTML") { result, error in
      if let html = result as? String, html.contains("http-equiv=\"refresh\"") {
        return completion(true)
      }

      return completion(false)
    }
  }

  func openDependingPage() {
    if webView.isLoading {
       webView.stopLoading()
    }

    guard let url = webView.url, url.absoluteString != "about:blank" else {
      connectorTryHttp()

      return;
    }

    switch isSecureBaseUrl(url: url) {
    case (secure: false, base: true): // state of maxima's man-in-the-middle
      checkWillRefresh { (willRefresh) -> Void in
        if willRefresh {
          // meta-equiv case
          // wait for <meta http-equiv=refresh> redirect
          ()
        } else {
          // http passed successful case
          // medium well
          self.connectorTryHttps()
        }
      }
      
    case (secure: false, base: false): // state of branded page
      if url.host?.contains("wi-fi") == false {
        // user clicked on ad, and so a branded page is loaded. go try http.
        connectorTryHttp()
      } else {
        // assume this is the first fake page. (or any other fake pages.)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(4500), execute: {
          self.simulateJS()
        })
        // wait for user action
        //cancel()
      }

    case (secure: true, base: true): // well done
      delegate?.connectorDidGetSecurePageMatchHost()

      finish()

    //case (secure: true, base: false): // ???
    //  connectorTryHttps()

    default:
      // why not?
      connectorTryHttp()
    }
  }

  override func execute() {
    DispatchQueue.main.async {
      self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: [.old, .new], context: nil)

      self.webView.navigationDelegate = self

      self.openDependingPage()
    }
  }

  override func finished(_ errors: [NSError]) {
    webView.removeObserver(self, forKeyPath: "estimatedProgress")
  }

}

// MARK: WKNavigationDelegate

extension OpenPageOperation: WKNavigationDelegate {

  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    delegate?.connectorDidStartLoad(url: webView.url?.absoluteString ?? "")
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    delegate?.connectorDidEndLoad(title: webView.title ?? "title", url: webView.url?.absoluteString ?? "url")

    openDependingPage()
  }

  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    delegate?.updateLog("didFailNavigation", error.localizedDescription)
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

extension OpenPageOperation {

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

