//
//  NetworkLogger.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/7/26.
//

import Foundation

public protocol NetworkLogable: Sendable {
  func requestLogger(request: URLRequest)
  func responseLogger(response: URLResponse, data: Data)
}
// MARK: - Logger
#if DEBUG
public final class NetworkLogger: NetworkLogable {
  public init() {}

  public func requestLogger(request: URLRequest) {
    print("")
    debugPrint("======================== 👉 Network Request Log 👈 ==========================")
    debugPrint("✅ [URL] : \(request.url?.absoluteString ?? "")")
    debugPrint("✅ [Method] : \(request.httpMethod ?? "")")
    debugPrint("✅ [Headers] : \(request.allHTTPHeaderFields ?? [:])")

    if let body = request.httpBody?.toPrettyPrintedString {
      debugPrint("✅ [Body] : \(body)")
    } else {
      debugPrint("✅ [Body] : body 없음")
    }
    debugPrint("==============================================================================")
    print("")
  }

  public func responseLogger(response: URLResponse, data: Data) {
    print("")
    debugPrint("======================== 👉 Network Response Log 👈 ==========================")

    guard let response = response as? HTTPURLResponse else {
      debugPrint("✅ [Response] : HTTPURLResponse 캐스팅 실패")
      return
    }

    debugPrint("✅ [StatusCode] : \(response.statusCode)")

    switch response.statusCode {
    case 400..<500:
      debugPrint("🚨 클라이언트 오류")
    case 500..<600:
      debugPrint("🚨 서버 오류")
    default:
      break
    }

    debugPrint("✅ [ResponseData] : \(data.toPrettyPrintedString ?? "")")
    debugPrint("===============================================================================")
    print("")
  }
}
#else
public final class Logger: NetworkLogable {
  public init() {}
  public func requestLogger(request: URLRequest) {}
  public func responseLogger(response: URLResponse, data: Data) {}
}
#endif

fileprivate extension Data {
  var toPrettyPrintedString: String? {
    guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
      let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
      let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
    else {
      return nil
    }
    return prettyPrintedString as String
  }
}
