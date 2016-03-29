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

typealias LoggerType = (prefix: String, text: String) -> Void

private let logSym = "〄"

enum CookieError: ErrorType {
  case WrongParameters
}

//github.com/m4rr/mosmetro-auth/blob/master/metro.py

class MosMetroAuth {

  private var logger: LoggerType

  init(logger: LoggerType) {
    self.logger = logger
  }

  private func updateLog(text: String) {
    logger(prefix: logSym, text: text)
  }

  func go() -> NSTimeInterval {
    let startTime = NSDate()

    if tryConnect("http://1.1.1.1/login.html") {
      for counter in 0..<3 {
        if tryConnect("https://wtfismyip.com/text") {
          if counter == 0 {
            updateLog("Already connected")
          } else {
            updateLog("Connected")
          }

          break
        }

        connect()
      }
    } else {
      updateLog("Wrong network")
    }

    return startTime.timeIntervalSinceNow
  }

  private func syncRequest(method: Alamofire.Method, _ address: String, parameters: [String: AnyObject]? = nil, headers: [String: String]? = nil, cookies:  [NSHTTPCookie]? = nil) -> (text: String?, response: NSHTTPURLResponse?) {

    updateLog(address)

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
    updateLog("tryConnect \(address)")

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
    let pageVmetro = syncRequest(.GET, "http://vmet.ro")
    guard let
      pageVmetroURL = pageVmetro.response?.URL,
      text = pageVmetro.text,
      urlAuthStr = matchesForRegexInText("https:[^\"]*", text: text).first
      else { return }

    let pageAuth = syncRequest(.GET, urlAuthStr,
                               headers: ["referer": pageVmetroURL.absoluteString],
                               cookies: pageVmetro.response?.cookies
    )
    guard let
      pageAuthURL = pageAuth.response?.URL,
      pageAuthText = pageAuth.text,
      pageAuthBody = matchesForRegexInText("<body>.*?</body>", text: pageAuthText).first
      else { return }


    let pagePostAuth = syncRequest(.POST, urlAuthStr,
                                   parameters: formInputParse(pageAuthBody),
                                   headers: ["referer": pageAuthURL.absoluteString],
                                   cookies: pageAuth.response?.cookies
    )
    guard let
      pagePostAuthURL = pagePostAuth.response?.URL,
      pagePostAuthBody = matchesForRegexInText("<body>.*?</body>", text: pagePostAuth.text).first
      else { return }

    // pageRouter
    let _ = syncRequest(.POST, "http://1.1.1.1/login.html",
                        parameters: formInputParse(pagePostAuthBody),
                        headers: ["referer": pagePostAuthURL.absoluteString],
                        cookies: pagePostAuth.response?.cookies
    )
  }

  // MARK: - Meta Helpers

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
      updateLog("invalid regex: \(error.localizedDescription)")
      return []
    }
  }

}

extension NSHTTPURLResponse {

  var cookies: [NSHTTPCookie]? {
    guard let hs = allHeaderFields as? [String : String], url = URL else { return nil }

    return NSHTTPCookie.cookiesWithResponseHeaderFields(hs, forURL: url)
  }

}
