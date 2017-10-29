//
//  AppDelegate.swift
//  mauth
//
//  Created by Marat S. on 20/09/15.
//  Copyright © 2015 emfo. All rights reserved.
//

import UIKit
import AVFoundation

//let didBecomeActiveNotification = Notification.Name.init("applicationDidBecomeActiveNotification")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  /// A `7 seconds ago` is a timeout to post notification of `becomeActive`.
  private let inactivityTimeout: TimeInterval = -7
  private lazy var resignActiveAt: NSDate = NSDate()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    tryDisableAudioSession()

    return true
  }

  func tryDisableAudioSession() {
    let session = AVAudioSession.sharedInstance()
    let _ = try? session.setCategory(AVAudioSessionCategoryAmbient)
    let _ = try? session.setActive(true)
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    resignActiveAt = NSDate()
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    // App was in background more than `timeout` constant. I.e if -10 < -7.
    if resignActiveAt.timeIntervalSinceNow < inactivityTimeout {
      //
    }
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
}
