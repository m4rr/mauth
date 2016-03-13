//
//  LoggerTableViewController.swift
//  mauth
//
//  Created by Marat S. on 30/09/15.
//  Copyright © 2015 emfo. All rights reserved.
//

import UIKit

class LoggerTableViewController: UITableViewController {

  private var log: [(String, AnyObject)] = [] // Array(NSUserDefaults.standardUserDefaults().dictionaryForKey("log") ?? [:])

  @IBAction func close(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  // MARK: - Table view data source

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return log.underestimateCount()
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

    //cell.textLabel?.text = log[indexPath.row]

    return cell
  }

  func data(indexPath: NSIndexPath) -> (String, AnyObject) {
    return log[indexPath.row]
  }

  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.textLabel?.text = data(indexPath).0
  }

  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let vc = segue.destinationViewController as? LogViewerController {
      vc.data = data(tableView.indexPathForSelectedRow!)
    }
  }

}
