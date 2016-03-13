//
//  NeatViewController.swift
//  mauth
//
//  Created by Marat S. on 11.12.15.
//  Copyright © 2015 m4rr. All rights reserved.
//

import UIKit
import WebKit
import PureLayout
import PKHUD

class NeatViewController: UIViewController {

  private lazy var webView = WKWebView()
  @IBOutlet weak var navBar: UIView!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var progressBar: UIProgressView!
  @IBOutlet weak var logTextView: UITextView!

  let operationQueue = OperationQueue()

  override func viewDidLoad() {
    super.viewDidLoad()

    setupWebView()
    startOperating()
    subscribeNotifications()
  }

  deinit {
    unsubscribeNotifications()
  }

  override func updateViewConstraints() {
    webView.autoPinEdge(.Left, toEdge: .Left, ofView: view)
    webView.autoPinEdge(.Right, toEdge: .Right, ofView: view)
    webView.autoPinEdge(.Top, toEdge: .Bottom, ofView: navBar)
    webView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: view)

    super.updateViewConstraints()
  }

  private func subscribeNotifications() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "startOperating", name: didBecomeActiveNotificationName, object: nil)
  }

  private func unsubscribeNotifications() {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  private func setupWebView() {
    let config = WKWebViewConfiguration()
    config.allowsInlineMediaPlayback = false
    config.suppressesIncrementalRendering = false

    if #available(iOS 9.0, *) {
      config.allowsAirPlayForMediaPlayback = false
      config.allowsPictureInPictureMediaPlayback = false
      config.requiresUserActionForMediaPlayback = true
    } else {
      config.mediaPlaybackRequiresUserAction = true
      config.mediaPlaybackAllowsAirPlay = false
    }

    //let cutAudioUserScript = WKUserScript(source: "var x = document.getElementsByClassName('audio'); var i; for (i = 0; i < x.length; i++) { x[i].outerHTML = ''; }", injectionTime: .AtDocumentEnd, forMainFrameOnly: false)
    //config.userContentController.addUserScript(userScript)

    webView = WKWebView(frame: view.bounds, configuration: config)

    if #available(iOS 9.0, *) {
        webView.customUserAgent = "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; InfoPath.3; .NET4.0C; .NET4.0E; FerrariGT)" // vertu user-agent :)
    } else {
        // Fallback on earlier versions
    }

    webView.alpha = 0.3

    view.insertSubview(webView, atIndex: 0)

    view.updateConstraintsIfNeeded()
  }

  func startOperating() {
    if #available(iOS 9.0, *) {
      webView.loadHTMLString("", baseURL: nil)
    } else {
      // Fallback on earlier versions
    }

    let operation = OpenPageOperation(webView: webView, delegate: self)
    operationQueue.addOperation(operation)

  }

  @IBAction func retryButtonTap(sender: AnyObject) {
    updateLog("⤴\u{fe0e}", "retry") // ⎋

    startOperating()
  }

}

extension NeatViewController: ConnectorDelegate { // KVO

  func updateLog(prefix: String, _ text: String) {
    let t = prefix + " " + text + "\n"
    logTextView.text = t + (logTextView.text ?? "")
  }

  func connectorDidStartLoad(url: String) {
    addressLabel.text = url

    updateLog("▶", url)
  }

  func connectorDidEndLoad(title: String, url: String) {
    addressLabel.text = url

    updateLog("◼", url)
  }

  func connectorProgress(old old: Float, new: Float) {
    progressBar.setProgress(new, animated: old < new)

    UIView.animateWithDuration(0.5) {
      self.progressBar.alpha = new < 1 ? 1 : 0
    }
  }

  func connectorDidGetSecurePageMatchHost() {
    showSuccessHUD()
  }

  func showSuccessHUD() {
    PKHUD.sharedHUD.contentView = PKHUDSuccessView()
    PKHUD.sharedHUD.dimsBackground = false
    PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
    PKHUD.sharedHUD.show()
    PKHUD.sharedHUD.hide(afterDelay: 2.0)
  }

}

extension NeatViewController {

  // MARK: JavaScript

  @IBAction func simulateJS(sender: UIButton?) {
    let aClick = [
      //"document.querySelector(\"a[href^='//']\").click();",
      "document.querySelector('a.disableAd').click();",
      "document.querySelector('#disableAd > a').click();",
      "document.querySelector('a.b-header__button is-on-left-side').click();",
    ]

    aClick.forEach { query in
      webView.evaluateJavaScript(query) { result, error in
        if let error = error where error.code == WKErrorCode.JavaScriptExceptionOccurred.rawValue {
          // clicking by defunct selectors guaranteed produce errors
        }
      }
    }
  }

  @IBAction func logSourceCode(sender: AnyObject) {
    let url = webView.URL?.absoluteString ?? ""
    let querySelector = "document.getElementsByTagName('html')[0].outerHTML"

    var log: [String: AnyObject] {
      get {
        return [:] // NSUserDefaults.standardUserDefaults().dictionaryForKey("log") ?? [:]
      }
      set {
        NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "log")
      }
    }

    webView.evaluateJavaScript(querySelector) { result, error in
      if let html = result as? String {
        // store log
        log[url] = html
      }
    }
  }


}
