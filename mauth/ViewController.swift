//
//  ViewController.swift
//  mauth
//
//  Created by Marat S. on 20/09/15.
//  Copyright © 2015 emfo. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation
import PureLayout
import PKHUD

let willResignActiveNotificationName = "applicationWillResignActiveNotificationName"
let didBecomeActiveNotificationName = "applicationDidBecomeActiveNotificationName"

class ViewController: UIViewController {

  private var webView: WKWebView!
  private var fakeWebView: WKWebView?

  @IBOutlet private weak var infoView: UIView!
  @IBOutlet private weak var addressLabel: UILabel!
  @IBOutlet private weak var progressBar: UIProgressView!

  private let baseUrl🔓 = NSURL(string: "http://ya.ru/")!
  private let baseUrl🔐 = NSURL(string: "https://ya.ru/")!
  private let url1111 = NSURL(string: "http://1.1.1.1/")!

  private var maybeCount = 0

  private lazy var request🔓: NSURLRequest = NSURLRequest(URL: self.baseUrl🔓, cachePolicy: .ReloadIgnoringCacheData, timeoutInterval: 1)
  private lazy var request🔐: NSURLRequest = NSURLRequest(URL: self.baseUrl🔐, cachePolicy: .ReloadIgnoringCacheData, timeoutInterval: 1)
  private var networkActivity = 0 {
    didSet {
      //UIApplication.sharedApplication().networkActivityIndicatorVisible = networkActivity != 0
    }
  }

  private lazy var userTappedOnce: Bool = false
  private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
    let tgr = UITapGestureRecognizer(target: self, action: "handleTap:")
    tgr.delegate = self
    return tgr
  }()

  private var log: [String: AnyObject] {
    get {
      return NSUserDefaults.standardUserDefaults().dictionaryForKey("log") ?? [:]
    }
    set {
      NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "log")
    }
  }

  // MARK: - Life

  override func viewDidLoad() {
    super.viewDidLoad()

    setupWebView()
    tryAuth()

    subscribeNotifications()

    let _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    subscribeNotifications()
  }

  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)

    unsubscribeNotifications()
  }

  deinit {
    unsubscribeNotifications()
  }

  // MARK: - UI

  @IBAction func tryAuth() {
    userTappedOnce = false
    makeDependingRequest(nil)
  }

  @IBAction func try1111() {
    userTappedOnce = false
    webView.loadRequest(NSURLRequest(URL: url1111))
  }

  @IBAction func simulateJS(sender: UIButton?) {
    let aClick = [
      "var a2 = document.querySelector(\"a[href^='https://ads.adfox']\"); a2.click();",
      "var a3 = document.querySelector(\"#content > a\"); a3.click();",
      "var a4 = document.querySelector(\"#content > a\"); a4[0].click();",
      "var a1 = document.querySelector(\"a[href^='//']\"); a1.click();",
    ]

    aClick.forEach { query in
      webView.evaluateJavaScript(query) { result, error in
        //if error == nil {
        self.userTappedOnce = true

        let statusTitle = "js ok" + (result == nil ? "" : " result")
        sender?.setTitle(statusTitle, forState: .Normal)
        //}
      }
    }
  }

  // MARK: - Helpers

  func subscribeNotifications() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeFakeFrame", name: willResignActiveNotificationName, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "tryAuth", name: didBecomeActiveNotificationName, object: nil)
  }

  func unsubscribeNotifications() {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  func makeDependingRequest(currentUrl: NSURL?) {

    let isBaseAndSecure = self.isSecureBaseUrl(currentUrl)

    switch isBaseAndSecure {
    case (true, true):
      doneAuthHUD()
    case (true, false):
      webView.loadRequest(request🔐)
    default:
      startAuthHUD()
      webView.loadRequest(request🔓)
    }

    if userTappedOnce {
      loadFakeUnsecureRequest()
    }
  }

  func loadFakeUnsecureRequest() {
    if fakeWebView == nil {
      fakeWebView = WKWebView(frame: CGRectZero, configuration: self.webView.configuration)
    }
    let q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    dispatch_async(q) { () -> Void in
      self.fakeWebView?.loadRequest(request🔓)
    }
  }

  func removeFakeFrame() {
    fakeWebView?.loadHTMLString("", baseURL: nil)
    fakeWebView = nil
  }

  // try test this shit
//  func massRequest() {
//    func s() {
//      usleep(UInt32(0.1 * pow(10, 6)))
//    }
//
//    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//    dispatch_async(queue) { () -> Void in
//      self.webView.loadRequest(self.request🔐)
//      s()
//      self.webView.loadRequest(self.request🔓)
//      s()
//      self.webView.loadRequest(self.request🔐)
//    }
//  }

  func logCurrent(completion: () -> Void) {
    webView.evaluateJavaScript("document.getElementsByTagName('html')[0].outerHTML") { result, error in
      if let html = result as? String {
        let url = self.webView.URL?.absoluteString ?? ""
        self.log[url] = html
      }

      completion()
    }
  }

  func startAuthHUD() {
    if PKHUD.sharedHUD.isVisible {
      return;
    }
    PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Trying...")
    PKHUD.sharedHUD.dimsBackground = true
    PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
    PKHUD.sharedHUD.show()
  }

  func doneAuthHUD() {
    PKHUD.sharedHUD.contentView = PKHUDSuccessView()
    PKHUD.sharedHUD.dimsBackground = false
    PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
    PKHUD.sharedHUD.show()
    PKHUD.sharedHUD.hide(afterDelay: 2.0)
  }

  // MARK: - Setup

  override func updateViewConstraints() {
    webView.autoPinEdge(.Top, toEdge: .Top, ofView: view, withOffset: 20)
    webView.autoPinEdge(.Bottom, toEdge: .Top, ofView: infoView)
    webView.autoPinEdge(.Left, toEdge: .Left, ofView: view)
    webView.autoPinEdge(.Right, toEdge: .Right, ofView: view)

    super.updateViewConstraints()
  }

  func setupWebView() {
    let config = WKWebViewConfiguration()
    config.allowsInlineMediaPlayback = false

//    if #available(iOS 9.0, *) {
      config.allowsAirPlayForMediaPlayback = false
      config.allowsPictureInPictureMediaPlayback = false
      config.requiresUserActionForMediaPlayback = true
//    } else {
//      config.mediaPlaybackRequiresUserAction = true
//      config.mediaPlaybackAllowsAirPlay = false
//    }

//    let userScript = WKUserScript(source: "var x = document.getElementsByClassName('audio'); var i; for (i = 0; i < x.length; i++) { x[i].outerHTML = ''; }", injectionTime: .AtDocumentEnd, forMainFrameOnly: false)
//    config.userContentController.addUserScript(userScript)

    webView = WKWebView(frame: view.bounds, configuration: config)
    webView.addObserver(self, forKeyPath: "estimatedProgress", options: [.Old, .New], context: nil)
    webView.scrollView.addGestureRecognizer(tapGestureRecognizer)
    webView.navigationDelegate = self
    webView.UIDelegate = self

    webView.alpha = 0.3

    view.insertSubview(webView, belowSubview: infoView)

    updateViewConstraints()
  }

}

extension ViewController { // KVO

  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    guard let keyPath = keyPath, change = change else {
      return;
    }

    switch keyPath {
    case "estimatedProgress":
      if let new = change["new"] as? Float, old = change["old"] as? Float {
        dispatch_async(dispatch_get_main_queue()) {
          self.progressBar.setProgress(new, animated: old < new)
        }
      }
    default:
      ()
    }
  }
  
}

// MARK: - UIGestureRecognizerDelegate

extension ViewController: UIGestureRecognizerDelegate {

  func handleTap(gestureRecognizer:UIGestureRecognizer) {
    userTappedOnce = true
  }

  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

}

// MARK: - WKNavigationDelegate

extension ViewController: WKNavigationDelegate {

  func isSecureBaseUrl(url: NSURL?) -> (base: Bool, secure: Bool) {
    return (url?.host == baseUrl🔐.host, url?.scheme == baseUrl🔐.scheme)
  }

//  func isBaseSecureUrl(url: NSURL?) -> Bool {
//    return url?.host == baseUrl🔓.host && url?.scheme == baseUrl🔐.scheme
//  }

  func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    ++networkActivity
    addressLabel.text = webView.URL?.absoluteString ?? ""
  }

  /**

  Firstly loaded http://ya.ru that redirected to metro auth page.

  After tap on ad, loads ad-page,
  and since userTappedOnce && webView.URL?.host != ya.ru, 
  trying to load https://ya.ru.
  
  Next guess: massRequest https—http—https.

  */

  func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
    --networkActivity
    logCurrent { () -> Void in
      let maybeLogin = webView.URL?.host?.hasPrefix("login") ?? false
      let isYandex = webView.URL?.host == self.baseUrl🔓.host
      if !isYandex && (!self.userTappedOnce || maybeLogin) {
        if maybeLogin {
          if ++self.maybeCount > 1 {
            self.performSelector("makeDependingRequest:", withObject: webView.URL, afterDelay: 1)

            return;
          }
        }
        self.performSelector("simulateJS:", withObject: nil, afterDelay: 2)
      } else {
        self.performSelector("makeDependingRequest:", withObject: webView.URL, afterDelay: 1)
      }
    }
  }

  func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
    --networkActivity
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

// MARK: - WKUIDelegate

extension ViewController: WKUIDelegate {

}
