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

typealias LoggerType = ([String]) -> Void

private let logSymbol = "〄"

enum AuthorizingError: ErrorType {
  case regex, urlString, connectionFaled
}

struct SyncRqResponse {
  let text: String?, response: NSHTTPURLResponse?
}

//github.com/m4rr/mosmetro-auth/blob/master/metro.py

class MosMetroAuth {

  private var logger: LoggerType

  init(logger: LoggerType) {
    self.logger = logger
  }

  private func updateLog(text: String...) {
    logger([logSymbol] + text)
  }

  private var headers: [String: String] = [:] {
    didSet {
      updateLog(#function, headers.debugDescription)
    }
  }

  func start() -> NSTimeInterval {
    let startTime = NSDate()

    // ping router
    if tryConnect("http://1.1.1.1/login.html") {
      connetionLoop: for counter in 0...2 {
        do {
          // get redirection
          let pageVmetro: SyncRqResponse = try syncRequest(.GET, "http://vmet.ro")
          headers["referer"] = pageVmetro.response?.URL?.absoluteString

          // get redirection target
          let urlAuth = try matchesForRegexInText("https?:[^\"]*", text: pageVmetro.text).first

          updateLog("Connecting...")
          try connect(urlAuth, cookies: pageVmetro.response?.cookies)

        } catch AuthorizingError.regex {
          updateLog("Regex failed")

        } catch AuthorizingError.connectionFaled {
          updateLog("Connection failed")

        } catch {
          if counter == 0 {
            updateLog("Already connected")
          } else {
            updateLog("Connected")
          }
          break connetionLoop
        }
      }
    } else {
      updateLog("Wrong network")
    }

    return startTime.timeIntervalSinceNow
  }

  private func syncRequest(
      method: Alamofire.Method,
    _ address: String,
      parameters: [String: AnyObject]? = nil,
      headers: [String: String]? = nil,
      cookies:  [NSHTTPCookie]? = nil) throws -> SyncRqResponse {

    updateLog(address)

    let semaphore = dispatch_semaphore_create(0)

    var response: NSHTTPURLResponse?, text: String?, error: NSError?

    if let cookies = cookies, url = NSURL(string: address) {
      Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.setCookies(cookies, forURL: url, mainDocumentURL: nil)
    }

    Alamofire
      .request(method, address, parameters: parameters, headers: headers)
      .responseString { rp in
        response = rp.response
        text = rp.result.value

        error = rp.result.error

        dispatch_semaphore_signal(semaphore)
    }

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

    if error != nil {
      throw error!
    }

    return SyncRqResponse(text: text, response: response)
  }

  private func tryConnect(address: String) -> Bool {
    updateLog(#function, address)

    var result = false

    guard let url = NSURL(string: address) else {
      return result
    }

    let request = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)

    let semaphore = dispatch_semaphore_create(0)

    NSURLSession.sharedSession().dataTaskWithRequest(request) { [unowned self] _, response, err in
      result = err == nil

      self.updateLog(#function, "response", response.debugDescription)

      dispatch_semaphore_signal(semaphore)
    }.resume()

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

    return result
  }

  private func connect(url: String?, cookies: [NSHTTPCookie]?) throws {
    guard let url = url else { throw AuthorizingError.urlString }

    do {
      // Запрашиваем страницу с кнопкой авторизации
      let pageAuth: SyncRqResponse = try syncRequest(.GET, url, headers: headers, cookies: cookies)
      headers["referer"] = pageAuth.response?.URL?.absoluteString

      // Парсим поля скрытой формы
      let pageAuthBody = try matchesForRegexInText("<body>.*?</body>", text: pageAuth.text).first
      let postData = formInputParse(pageAuthBody)

      let _ = try syncRequest(.POST, url,
                              parameters: postData,
                              headers: headers,
                              cookies: pageAuth.response?.cookies)
    }
  }

  // MARK: - Meta Helpers

  private func formInputParse(body: String?) -> [String: String] {
    var data: [String: String] = [:]

    guard let body = body else { return data }

    if let doc = Kanna.HTML(html: body, encoding: NSUTF8StringEncoding) {
      for input in doc.css("input") {
        data[input["name"]!] = input["value"]
      }
    }

    return data
  }

  private func matchesForRegexInText(regex: String!, text: String?) throws -> [String] {
    guard let text = text else {
      throw AuthorizingError.regex
    }

    do {
      let regex = try NSRegularExpression(pattern: regex, options: [])

      let range = NSRange(0...text.characters.count)
      let results = regex.matchesInString(text, options: [], range: range)

      return results.map {
        NSString(string: text).substringWithRange($0.range)
      }
    } catch let error as NSError {
      updateLog("invalid regex: \(error.localizedDescription)")
      throw AuthorizingError.regex
    }
  }

}

extension NSHTTPURLResponse {

  var cookies: [NSHTTPCookie]? {
    guard let headers = allHeaderFields as? [String : String], url = URL else { return nil }

    return NSHTTPCookie.cookiesWithResponseHeaderFields(headers, forURL: url)
  }

}
