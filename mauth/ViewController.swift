//
//  ViewController.swift
//  mauth
//
//  Created by Marat S. on 20/09/15.
//  Copyright © 2015 emfo. All rights reserved.
//

import UIKit
import WebKit
import PureLayout

class ViewController: UIViewController {

  private var webView: WKWebView!
  @IBOutlet private weak var infoView: UIView!
  @IBOutlet private weak var addressLabel: UILabel!

  private let baseUrl🔓 = NSURL(string: "http://ya.ru/")!
  private let baseUrl🔐 = NSURL(string: "https://ya.ru/")!
  private let url1111 = NSURL(string: "http://1.1.1.1/")!

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

  // MARK: - UI

  @IBAction func tryAuth() {
    userTappedOnce = false
    makeDependingRequest()
  }

  @IBAction func try1111() {
    userTappedOnce = false
    webView.loadRequest(NSURLRequest(URL: url1111))
  }

  @IBAction func simulateJS(sender: UIButton?) {
    let aClick = [
      //"var a1 = document.querySelector('a[href^=\"//\"]'); a1.click();",
      "var a2 = document.querySelector('a[href^=\"https://ads.adfox\"]'); a2.click();",
      "var a3 = document.querySelector('#content > a'); a3.click();",
      "var a4 = document.querySelector('#content > a'); a4[0].click();",
    ]

    webView.evaluateJavaScript(aClick.reduce("", combine: +)) { result, error in
      if error == nil {
        self.userTappedOnce = true

        let statusTitle = "js ok" + (result == nil ? "" : " result")
        sender?.setTitle(statusTitle, forState: .Normal)
      }
    }
  }

  // MARK: - Helpers

  func makeDependingRequest() {
    webView.loadRequest(userTappedOnce ? request🔐 : request🔓)
  }

  func logCurrent(completion: () -> Void) {
    webView.evaluateJavaScript("document.getElementsByTagName('html')[0].outerHTML") { result, error in
      if let html = result as? String {
        let url = self.webView.URL?.absoluteString ?? ""
        self.log[url] = html
      }

      completion()
    }
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
    config.allowsAirPlayForMediaPlayback = false
    config.allowsInlineMediaPlayback = false
    config.allowsPictureInPictureMediaPlayback = false
    config.requiresUserActionForMediaPlayback = true

    webView = WKWebView(frame: view.bounds, configuration: config)
    webView.scrollView.addGestureRecognizer(tapGestureRecognizer)
    webView.navigationDelegate = self
    webView.UIDelegate = self

    view.insertSubview(webView, belowSubview: infoView)

    updateViewConstraints()
  }

  // MARK: - Life

  override func viewDidLoad() {
    super.viewDidLoad()

    setupWebView()
    tryAuth()
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

  func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    ++networkActivity
    addressLabel.text = webView.URL?.absoluteString ?? ""
  }

  func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
    --networkActivity
    logCurrent { () -> Void in
      let isBase = webView.URL?.host == self.baseUrl🔓.host
      if !isBase && self.userTappedOnce {
        //performSelector("tryAuth", withObject: nil, afterDelay: 0.1)
        self.makeDependingRequest()
      }
    }
  }

  func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
    --networkActivity
  }

}

// MARK: - WKUIDelegate

extension ViewController: WKUIDelegate {

}
