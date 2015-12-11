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

  private var connector: Connector?

  override func viewDidLoad() {
    super.viewDidLoad()

    setupWebView()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    connector = Connector(webView: webView)
    webView.navigationDelegate = connector
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func updateViewConstraints() {
    webView.autoPinEdgesToSuperviewEdges()

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
    webView.addObserver(self, forKeyPath: "estimatedProgress", options: [.Old, .New], context: nil)
//    webView.scrollView.addGestureRecognizer(tapGestureRecognizer)
    webView.navigationDelegate = connector

    webView.alpha = 0.2

    view.addSubview(webView)

    view.setNeedsUpdateConstraints()
  }



  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */

}



extension NeatViewController { // KVO

  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    guard let keyPath = keyPath, change = change else {
      return;
    }

    switch keyPath {
    case "estimatedProgress":
      if let new = change["new"] as? Float, old = change["old"] as? Float {
        print(new)
        dispatch_async(dispatch_get_main_queue()) {
//          self.progressBar.setProgress(new, animated: old < new)
        }
      }
    default:
      ()
    }
  }
  
}



