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
  }

  override func updateViewConstraints() {
    webView.autoPinEdge(.Left, toEdge: .Left, ofView: view)
    webView.autoPinEdge(.Right, toEdge: .Right, ofView: view)
    webView.autoPinEdge(.Top, toEdge: .Bottom, ofView: navBar)
    webView.autoPinEdge(.Bottom, toEdge: .Top, ofView: logTextView)

    super.updateViewConstraints()
  }

  func setupWebView() {
    let config = WKWebViewConfiguration()
    config.allowsInlineMediaPlayback = false
    config.suppressesIncrementalRendering = true

    if #available(iOS 9.0, *) {
      config.allowsAirPlayForMediaPlayback = false
      config.allowsPictureInPictureMediaPlayback = false
      config.requiresUserActionForMediaPlayback = true
    } else {
      config.mediaPlaybackRequiresUserAction = true
      config.mediaPlaybackAllowsAirPlay = false
    }

    //    let userScript = WKUserScript(source: "var x = document.getElementsByClassName('audio'); var i; for (i = 0; i < x.length; i++) { x[i].outerHTML = ''; }", injectionTime: .AtDocumentEnd, forMainFrameOnly: false)
    //    config.userContentController.addUserScript(userScript)

    webView = WKWebView(frame: view.bounds, configuration: config)
//    webView.scrollView.contentInset.top = 20
//    webView.scrollView.addGestureRecognizer(tapGestureRecognizer)

    if #available(iOS 9.0, *) {
        webView.customUserAgent = "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; nb-no) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8C148a Safari/6533.18.5"
    } else {
        // Fallback on earlier versions
    }

    webView.alpha = 0.3


    navigationController?.navigationBarHidden = false

    view.insertSubview(webView, atIndex: 0)

    view.setNeedsUpdateConstraints()
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


  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */

  @IBAction func retryButtonTap(sender: AnyObject) {
    updateLog("  //", "retry")

    startOperating()
    uiscroll
  }

}



extension NeatViewController: ConnectorDelegate { // KVO

  func updateLog(prefix: String = "", _ text: String) {
    logTextView.text = (logTextView.text ?? "") + prefix + " " + text + "\n"
//    logTextView.setContentOffset()

  }

  func connectorDidStartLoad(url: String) {
    addressLabel.text = url
    updateLog("StartLoad", url)
  }

  func connectorDidEndLoad(title: String, url: String) {
    addressLabel.text = url
    updateLog("EndLoad", url)
  }

  func connectorProgress(old old: Float, new: Float) {
    progressBar.setProgress(new, animated: old < new)

    UIView.animateWithDuration(0.5) {
      self.progressBar.alpha = new < 1 ? 1 : 0
    }
  }
  
}



