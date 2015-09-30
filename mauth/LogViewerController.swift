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

  var data: (String, AnyObject)!

  private var html: String {
    return (data.1 as? String) ?? ""
  }

  @IBOutlet weak var textView: UITextView!

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share")
    navigationItem.title = data.0

    textView.text = html
  }

  func share() {
    let sendComposer = MFMailComposeViewController()
    sendComposer.mailComposeDelegate = self
    sendComposer.setToRecipients(["remarr@gmail.com"])
    sendComposer.setSubject("mauth log \(data.0)")
    sendComposer.setMessageBody(textView.text, isHTML: false)
    presentViewController(sendComposer, animated: true, completion: nil)
  }

}

extension LogViewerController: MFMailComposeViewControllerDelegate {

  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    controller.dismissViewControllerAnimated(true, completion: nil)
  }

}
