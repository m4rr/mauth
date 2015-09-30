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

class TappingWebView: WKWebView {
//  var tapped = false

//  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//    super.touchesEnded(touches, withEvent: event)
//
//
//    tapped = true
//  }
}

class ViewController: UIViewController {

  @IBOutlet weak var infoView: UIView!
  @IBOutlet weak var addressLabel: UILabel!

  private var webView: TappingWebView!

  private let baseUrl = NSURL(string: "http://ya.ru/")!
  private let url1111 = NSURL(string: "http://1.1.1.1/")!
  private var userTappedOnce: Bool = false

  private lazy var request: NSURLRequest = {
    return NSURLRequest(URL: self.baseUrl, cachePolicy: .ReloadIgnoringCacheData, timeoutInterval: 60)
    }()

  override func viewDidLoad() {
    super.viewDidLoad()

    setupWebView()
    tryAuth()
  }

  lazy var gr: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")

  func setupWebView() {
    let config = WKWebViewConfiguration()
    config.allowsAirPlayForMediaPlayback = false
    config.allowsInlineMediaPlayback = false
    config.allowsPictureInPictureMediaPlayback = false
    config.requiresUserActionForMediaPlayback = true

    webView = TappingWebView(frame: view.bounds, configuration: config)
    webView.navigationDelegate = self
    webView.UIDelegate = self

    view.addSubview(webView)
    view.sendSubviewToBack(webView)

    webView.scrollView.addGestureRecognizer(gr)
    gr.delegate = self

    updateViewConstraints()
  }

  @IBAction func tryAuth() {
    userTappedOnce = false
    webView.loadRequest(request)
  }

  @IBAction func try1111() {
    userTappedOnce = false
    webView.loadRequest(NSURLRequest(URL: url1111))
  }

  var log: [String: AnyObject] {
    get {
      return NSUserDefaults.standardUserDefaults().dictionaryForKey("log") ?? [:]
    }
    set {
      NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "log")
    }
  }

  func addToLog(url: String, html: String) {
    log[url] = html
  }

  @IBAction func simulateJS(sender: UIButton?) {
    webView.evaluateJavaScript("var myLink = document.getElementById('myLink'); myLink.click();") { (rs: AnyObject?, er: NSError?) -> Void in
      //
    }
  }


  func logCurrent(completion: () -> Void) {
    webView.evaluateJavaScript("document.getElementsByTagName('html')[0].outerHTML") { (rs, er) -> Void in

      if let html = rs as? String {
        self.addToLog(self.webView.URL?.absoluteString ?? "", html: html)
      }

      completion()
    }

  }


  override func updateViewConstraints() {
    webView.autoPinEdge(.Top, toEdge: .Top, ofView: view, withOffset: 20)
    webView.autoPinEdge(.Bottom, toEdge: .Top, ofView: infoView)
    webView.autoPinEdge(.Left, toEdge: .Left, ofView: view)
    webView.autoPinEdge(.Right, toEdge: .Right, ofView: view)

    super.updateViewConstraints()
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //
  }

}

extension ViewController: UIGestureRecognizerDelegate {

  func handleTap(gestureRecognizer:UIGestureRecognizer) {
    userTappedOnce = true
  }

  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

}

extension ViewController: WKNavigationDelegate {

  func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    addressLabel.text = webView.URL?.absoluteString ?? ""
  }

  func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
    logCurrent { () -> Void in
      let isBase = webView.URL?.host == self.baseUrl.host
      if !isBase && self.userTappedOnce {
        //performSelector("tryAuth", withObject: nil, afterDelay: 0.1)
        self.tryAuth()
      }
    }
  }

  func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
    //
  }

}

extension ViewController: WKUIDelegate {

}
