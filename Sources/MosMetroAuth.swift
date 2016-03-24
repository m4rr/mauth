//
//  mosmetroauth.swift
//  mauth
//
//  Created by Marat S. on 21/03/16.
//  Copyright © 2016 m4rr. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

//github.com/m4rr/mosmetro-auth/blob/master/metro.py

class MosMetroAuth {

  private func syncRequest(
    method: Alamofire.Method,
    _ address: String,
    parameters: [String: AnyObject]? = nil,
    headers: [String: String]? = nil,
    cookies:  [NSHTTPCookie]? = nil
    ) -> (text: String?, response: NSHTTPURLResponse?) {

      let semaphore = dispatch_semaphore_create(0)

      var response: NSHTTPURLResponse?
      var text: String?

      if let cookies = cookies, url = NSURL(string: address) {
        Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.setCookies(cookies, forURL: url, mainDocumentURL: nil)
      }

      Alamofire
        .request(method, address, parameters: parameters, headers: headers)
        .responseString { rp in
          response = rp.response
          text = rp.result.value

          dispatch_semaphore_signal(semaphore)
      }

      dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
      
      return (text, response)
  }

  private func tryConnect(address: String) -> Bool {
    var result = false

    guard let url = NSURL(string: address) else {
      return result
    }

    let rq = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)

    let semaphore = dispatch_semaphore_create(0)

    NSURLSession.sharedSession().dataTaskWithRequest(rq) { _, _, err in
      result = err == nil

      dispatch_semaphore_signal(semaphore)
    }.resume()

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

    return result
  }

  private func connect() {
    var headersSet: [String: String] = [:]

    let pageVmetro = syncRequest(.GET, "http://vmet.ro")
    guard let
      pageVmetroURL = pageVmetro.response?.URL,
      text = pageVmetro.text,
      urlAuthStr = matchesForRegexInText("https:[^\"]*", text: text).first,
      headers1 = pageVmetro.response?.allHeaderFields as? [String : String]
      else { return }
    headersSet["referer"] = pageVmetroURL.absoluteString

    let pageAuth = syncRequest(.GET, urlAuthStr,
      headers: headersSet,
      cookies: NSHTTPCookie.cookiesWithResponseHeaderFields(headers1, forURL: pageVmetroURL))
    guard let
      pageAuthURL = pageAuth.response?.URL,
      pageAuthText = pageAuth.text,
      pageAuthBody = matchesForRegexInText("<body>.*?</body>", text: pageAuthText).first,
      headers2 = pageAuth.response?.allHeaderFields as? [String : String]
      else { return }
    headersSet["referer"] = pageAuthURL.absoluteString

    let pagePostAuth = syncRequest(.POST, urlAuthStr,
      parameters: formInputParse(pageAuthBody),
      headers: headersSet,
      cookies: NSHTTPCookie.cookiesWithResponseHeaderFields(headers2, forURL: pageAuthURL))
    guard let
      pagePostAuthURL = pagePostAuth.response?.URL,
      pagePostAuthBody = matchesForRegexInText("<body>.*?</body>", text: pagePostAuth.text).first,
      headers3 = pagePostAuth.response?.allHeaderFields as? [String : String]
      else { return }
    headersSet["referer"] = pagePostAuthURL.absoluteString

    let pageRouter = syncRequest(.POST, "http://1.1.1.1/login.html",
      parameters: formInputParse(pagePostAuthBody),
      headers: headersSet,
      cookies: NSHTTPCookie.cookiesWithResponseHeaderFields(headers3, forURL: pagePostAuthURL))
  }

  func go() -> NSTimeInterval {
    let startTime = NSDate()

    if tryConnect("http://1.1.1.1/login.html") {
      for counter in 0..<3 {
        if tryConnect("https://wtfismyip.com/text") {
          if counter == 0 {
            print("Already connected")
          } else {
            print("Connected")
          }

          break
        }

        connect()
      }
    } else {
      print("Wrong network")
    }

    return startTime.timeIntervalSinceNow
  }

  init() {
//    go()
  }

  private func formInputParse(body: String) -> [String: String] {
    var data: [String: String] = [:]

    if let doc = Kanna.HTML(html: body, encoding: NSUTF8StringEncoding) {
      for input in doc.css("input") {
        data[input["name"]!] = input["value"]
      }
    }

    return data
  }

  private func matchesForRegexInText(regex: String!, text: String!) -> [String] {
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
