//
//  LogViewerController.swift
//  mauth
//
//  Created by Marat S. on 30/09/15.
//  Copyright © 2015 emfo. All rights reserved.
//

import UIKit
import MessageUI

class LogViewerController: UIViewController {

  @IBOutlet weak var textView: UITextView!

  override func viewDidLoad() {
    super.viewDidLoad()

    LogManager.shared.logSourceCode { (host, text) -> Void in
      self.navigationItem.title = host
      self.textView.text = text
    }
  }

  @IBAction func shareByEmail(sender: AnyObject) {
    let host = navigationItem.title ?? ""
    let sendComposer = MFMailComposeViewController()
    sendComposer.mailComposeDelegate = self
    sendComposer.setToRecipients(["remarr@gmail.com"])
    sendComposer.setSubject("mauth log " + host)
    sendComposer.setMessageBody(textView.text, isHTML: false)
    present(sendComposer, animated: true, completion: nil)
  }

}

extension LogViewerController: MFMailComposeViewControllerDelegate {

  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true, completion: nil)
  }

}
