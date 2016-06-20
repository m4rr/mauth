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

public typealias LoggerType = ([String]) -> Void

private let logSymbol = "〄"

public enum AuthorizingError: ErrorType {
  case regex, urlString, connectionFaled
}

//github.com/m4rr/mosmetro-auth/blob/master/metro.py

public final class MosMetroAuth {

  private struct SyncResponse {
    let text: String?, response: NSHTTPURLResponse?
  }
  
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
    if checkConnection(to: "http://1.1.1.1/login.html") {
      connetionLoop: for counter in 0...2 {
        do {
          // get redirection
          let pageVmetro: SyncResponse = try syncRequest(.GET, "http://vmet.ro")
          headers["referer"] = pageVmetro.response?.URL?.absoluteString

          // get redirection target
          let urlAuth = try matches(regex: "https?:[^\"]*", in: pageVmetro.text).first

          updateLog("Connecting...")
          try obtainMetroConnection(urlAuth, cookies: pageVmetro.response?.cookies)

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

  private func checkConnection(to address: String) -> Bool {
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

  private func obtainMetroConnection(url: String?, cookies: [NSHTTPCookie]?) throws {
    guard let url = url else { throw AuthorizingError.urlString }

    do {
      // Запрашиваем страницу с кнопкой авторизации
      let pageAuth: SyncResponse = try syncRequest(.GET, url, headers: headers, cookies: cookies)
      headers["referer"] = pageAuth.response?.URL?.absoluteString

      // Парсим поля скрытой формы
      let pageAuthBody = try matches(regex: "<body>.*?</body>", in: pageAuth.text).first
      let postData = parseFormInputs(pageSource: pageAuthBody)

      let _ = try syncRequest(.POST, url,
                              parameters: postData,
                              headers: headers,
                              cookies: pageAuth.response?.cookies)
    }
  }

  private enum Method: String {
    case GET, POST
  }

  private func makeSyncRequest(method method: Method,
                                      address: String,
                                      parameters: [String: AnyObject]? = nil,
                                      headers: [String: String]? = nil,
                                      cookies:  [NSHTTPCookie]? = nil) throws -> SyncResponse {

    guard let url = NSURL(string: address) else {
      throw AuthorizingError.urlString
    }

    let rq = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)

    rq.HTTPMethod = method.rawValue

    headers?.forEach { key, value in
      rq.setValue(value, forHTTPHeaderField: key)
    }

    rq.HTTPShouldHandleCookies = true
    if let cookies = cookies {
      NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: url, mainDocumentURL: nil)
    }

    rq.HTTPBody = parameters?.reduce(String()) { "\($0)=\($1)&" }
      .dataUsingEncoding(NSUTF8StringEncoding)


    let semaphore = dispatch_semaphore_create(0)
    var result: Bool = false, response: NSHTTPURLResponse?, text: String?, error: NSError?

    NSURLSession.sharedSession().dataTaskWithRequest(rq) { [unowned self] _, response, err in
      result = err == nil

      self.updateLog(#function, "response", response.debugDescription)

      dispatch_semaphore_signal(semaphore)
    }.resume()
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

    return SyncResponse()
  }

  private func syncRequest(
    method: Alamofire.Method,
  _ address: String,
    parameters ps: [String: AnyObject]? = nil,
    headers hs: [String: String]? = nil,
    cookies:  [NSHTTPCookie]? = nil) throws -> SyncResponse {

    updateLog(address)

    if let cookies = cookies, url = NSURL(string: address) {
      let storage = Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage
      storage.setCookies(cookies, forURL: url, mainDocumentURL: nil)
    }

    let semaphore = dispatch_semaphore_create(0)
    var response: NSHTTPURLResponse?, text: String?, error: NSError?

    Alamofire
      .request(method, address, parameters: ps, headers: hs)
      .responseString { response in
        response = response.response
        text     = response.result.value
        error    = response.result.error

        dispatch_semaphore_signal(semaphore)
    }

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

    if let error = error {
      throw error
    } else {
      return SyncRqResponse(text: text, response: response)
    }
  }

  // MARK: - Meta Helpers

  /// Parsing html `<input />` in `pageSource`.
  private func parseFormInputs(pageSource pageSource: String?) -> [String: String] {
    var data: [String: String] = [:]

    guard let pageSource = pageSource else { return data }

    if let doc = Kanna.HTML(html: pageSource, encoding: NSUTF8StringEncoding) {
      for input in doc.css("input") {
        data[input["name"]!] = input["value"]
      }
    }

    return data
  }

  private func matches(regex regex: String!, in text: String?) throws -> [String] {
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

private extension NSHTTPURLResponse {

  var cookies: [NSHTTPCookie]? {
    guard let headers = allHeaderFields as? [String: String], url = URL else { return nil }

    return NSHTTPCookie.cookiesWithResponseHeaderFields(headers, forURL: url)
  }

}
