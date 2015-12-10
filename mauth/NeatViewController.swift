//
//  NeatViewController.swift
//  mauth
//
//  Created by Marat S. on 11.12.15.
//  Copyright © 2015 m4rr. All rights reserved.
//

import UIKit

class NeatViewController: UIViewController {

  let noteCenter = NSNotificationCenter.defaultCenter()

  lazy var connector = ConnectorLogic()


  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
