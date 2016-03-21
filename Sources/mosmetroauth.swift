//
//  mosmetroauth.swift
//  mauth
//
//  Created by Marat S. on 21/03/16.
//  Copyright © 2016 m4rr. All rights reserved.
//

import Foundation

//github.com/m4rr/mosmetro-auth/blob/master/metro.py

class MosMetroAuth {

  func syncGet(address: String) -> NSURLResponse {
    guard let url = NSURL(string: address) else {
      return NSURLResponse()
    }

    let rq = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)

    let semaphore = dispatch_semaphore_create(0)

    var data: NSData?, response: NSURLResponse?, error: NSError?

    NSURLSession.sharedSession().dataTaskWithRequest(rq) { (_dt: NSData?, _rp: NSURLResponse?, _err: NSError?) -> Void in
      data = _dt
      response = _rp
      error = _err

      dispatch_semaphore_signal(semaphore)
    }

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

    guard let
      data = data,
      text = String(data: data, encoding: NSUTF8StringEncoding),
      urlAuth = self.matchesForRegexInText("https:[^\"]*", text: text).first,
      headers = (rp as? NSHTTPURLResponse)?.allHeaderFields as? [String : String]
      else {
        return
    }


    let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headers, forURL: url) /// ...



  }

  func tryConnect(address: String) -> Bool {
    var result = false

    guard let url = NSURL(string: address) else {
      return result
    }

    let rq = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)

    let semaphore = dispatch_semaphore_create(0)

    NSURLSession.sharedSession().dataTaskWithRequest(rq) { _, _, err in
      result = err == nil

      dispatch_semaphore_signal(semaphore)
    }

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

    return result
  }

  func connect() {
    var headers: [String: AnyObject] = [:]



  }

  init() {

  }

  func matchesForRegexInText(regex: String!, text: String!) -> [String] {
    do {
      let regex = try NSRegularExpression(pattern: regex, options: [])
      let nsString = text as NSString
      let results = regex.matchesInString(text,
        options: [], range: NSMakeRange(0, nsString.length))
      return results.map { nsString.substringWithRange($0.range)}
    } catch let error as NSError {
      print("invalid regex: \(error.localizedDescription)")
      return []
    }
  }


}
