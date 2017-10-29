//
//  NeatViewController.swift
//  mauth
//
//  Created by Marat S. on 11.12.15. (First vesion — on 20.09.15: commit 2b3a696.)
//  Copyright © 2015 m4rr. All rights reserved.
//

import UIKit
import WebKit
import PKHUD

/**

 Firstly loaded http-page that redirected to the auth page.
 Tap on ad loads an ad-page.
 After that trying to load a https-page.

 */

enum UnitedStates {
  case warmUp, connectToUnsecure, connectToHTTPS, done

  mutating func next() {
    switch self {
    case .warmUp: self = .connectToUnsecure
    case .connectToUnsecure: self = .connectToHTTPS
    case .connectToHTTPS: self = .done
    case .done: return self = .done
    }
  }
}

class NeatViewController: UIViewController {

  var delegate: ConnectorDelegate? {
    return self
  }

  lazy var webView = WKWebView()
  @IBOutlet weak var navBar: UIView!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var progressBar: UIProgressView!
  @IBOutlet weak var logTextView: UITextView!
  @IBOutlet var quickOpenView: UIView!

  var state = UnitedStates.warmUp {
    didSet {
      switch (oldValue, state) {
      case (_, .connectToUnsecure):
        connectorTryHttp()
      case (_, .connectToHTTPS):
        connectorTryHttps()
      case (_, .done):
        showSuccessHUD()
      default:
        ()
      }
    }
  }

  lazy var reachability = Reachability.forInternetConnection()

  override func viewDidLoad() {
    super.viewDidLoad()

    setupQuickOpenView()
    setupWebView()
    startOperating()
    subscribeNotifications()

    let _ = LogManager(webView: webView)

    #if !DEBUG
      logTextView.userInteractionEnabled = false
    #endif
  }

  deinit {
    unsubscribeNotifications()
  }

  override func updateViewConstraints() {
    webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
    webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

    quickOpenView.centerXAnchor.constraint(equalTo: logTextView.centerXAnchor).isActive = true
    quickOpenView.centerYAnchor.constraint(equalTo: logTextView.centerYAnchor).isActive = true

    super.updateViewConstraints()
  }

  private func subscribeNotifications() {
//    NotificationCenter.default.addObserver(self, selector: #selector(startOperating), name: .UIApplicationDidBecomeActive, object: nil)
  }

  private func unsubscribeNotifications() {
    NotificationCenter.default.removeObserver(self)
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

    webView = WKWebView(frame: view.bounds, configuration: config)
    webView.alpha = 0.3
    webView.navigationDelegate = self
    webView.translatesAutoresizingMaskIntoConstraints = false
    
    if #available(iOS 9.0, *) {
      webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 10_2_1 like Mac OS X) AppleWebKit/602.4.6 (KHTML, like Gecko) Version/10.0 Mobile/14D27 Safari/602.1"
    } else {
      // Fallback on earlier versions
    }

    view.insertSubview(webView, at: 0)
    view.updateConstraintsIfNeeded()
  }

  private func setupQuickOpenView() {
    view.addSubview(quickOpenView)
    //quickOpenView.layer.borderColor = UIColor(white: 0.8, alpha: 1).CGColor
    quickOpenView.layer.borderWidth = 0
    quickOpenView.layer.cornerRadius = 2
    quickOpenView.layer.shadowColor = UIColor(white: 0.5, alpha: 1).cgColor
    quickOpenView.layer.shadowOffset = CGSize(width: 0, height: 2)
    quickOpenView.layer.shadowOpacity = 1
    quickOpenView.layer.shadowRadius = 5
    quickOpenView.translatesAutoresizingMaskIntoConstraints = false

    quickOpenView.subviews.forEach {
      $0.layer.cornerRadius = 2
    }
  }

  /// This also used via selector.
  @objc func startOperating() {
    hideQuickOpen()

    if #available(iOS 9.0, *) {
      webView.loadHTMLString("", baseURL: nil)
    } else {
      // Fallback on earlier versions
    }

    state.next()
  }


  @IBAction func retryButtonTap(sender: Any) {
    updateLog("⤴\u{fe0e}", NSLocalizedString("Retry", comment: "Retry (log)")) // ⎋

    startOperating()
  }



  // Shake-shake-shake.
  override var canBecomeFirstResponder: Bool {
    return true
  }

  // Shake gesture to view source code.
  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
    #if !DEBUG
      return;
    #endif

    if motion == .motionShake {
      performSegue(withIdentifier: "show-source-code", sender: nil)
    }
  }

  // Unwind from source code viewer to here.
  @IBAction func unwindToNeat(segue: UIStoryboardSegue) {

  }

}

// MARK: ConnectorDelegate

extension NeatViewController: ConnectorDelegate {

  func updateLog(_ prefix: String, _ text: String) -> Void {
    #if !DEBUG
      return;
    #endif

    DispatchQueue.main.async {
      let t = prefix + " " + text + "\n"
      self.logTextView.text = t + (self.logTextView.text ?? "")
    }
  }

  func connectorDidStartLoad(url: String) {
    addressLabel.text = url

    updateLog("▶", url)
  }



  func connectorDidEndLoad(title: String, url: URL?) {
    let urlStr = url?.absoluteString ?? "—"
    addressLabel.text = urlStr
    updateLog("◼", urlStr)
  }

  func connectorProgress(old: Float, new: Float) {
    progressBar.setProgress(new, animated: old < new)

    UIView.animate(withDuration: 0.5) {
      self.progressBar.alpha = new < 1 ? 1 : 0
    }
  }

  func connectorDidGetSecurePageMatchHost() {
    showSuccessHUD()
    showQuickOpen()
  }

  private func showSuccessHUD() {
    PKHUD.sharedHUD.contentView = PKHUDSuccessView()
    PKHUD.sharedHUD.dimsBackground = false
    PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
    PKHUD.sharedHUD.show()
    PKHUD.sharedHUD.hide(afterDelay: 2.0)
  }

  private func hideQuickOpen() {
    quickOpenView.isHidden = true
  }

  private func showQuickOpen() {
    quickOpenView.alpha = 0
    quickOpenView.isHidden = false

    UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn,
      animations: {
        self.quickOpenView.alpha = 1
      }, completion: nil)
  }

}

// MARK: UI Actions

extension NeatViewController {

  private func openURL(urlString: String) {
    guard let url = URL(string: urlString) else {
      return
    }

    if UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.openURL(url)
    }
  }

  @IBAction func openTwitter(sender: UIButton) {
    openURL(urlString: "twitter://")
  }

  @IBAction func openFacebook(sender: UIButton) {
    openURL(urlString: "fb://")
  }

  @IBAction func openVk(sender: UIButton) {
    openURL(urlString: "vk://")
  }

  @IBAction func openInstagram(sender: UIButton) {
    openURL(urlString: "instagram://")
  }

  @IBAction func openSafari(sender: UIButton) {
    openURL(urlString: "https://www.apple.com")
  }

  @IBAction func rateOnAppStore(sender: UIButton) {
    let appId = "1041801794"
    //let appLink = "itms-apps://itunes.apple.com/app/id" + appId
    //let appLink = "https://itunes.apple.com/app/moskva.-metro.-avtorizacia/id1041801794?mt=8"
    let appLink = "https://itunes.apple.com/app/viewContentsUserReviews?id=\(appId)"
    openURL(urlString: appLink)
  }

}

/// Parttern matching of Optional<String> for the "accessibilityIdentifier" case.
func ~=(lhs: String, rhs: String?) -> Bool {
  return lhs == rhs
}
