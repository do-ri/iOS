//
//  NetworkError.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/7/26.
//

import Foundation

// MARK: - Network Error
public enum NetworkError: Error, LocalizedError {
  case invalidURL
  case invalidResponse
  case noData
  case encoding(_ error: Error)
  case decoding(_ error: Error)
  case network(_ error: Error)
  case http(statusCode: Int, message: String)
  case unauthorized
  case forbidden
  case notFound
  
  public var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "잘못된 URL입니다."
    case .invalidResponse:
      return "잘못된 응답입니다."
    case .noData:
      return "데이터가 없습니다."
    case .encoding(let error):
      return "인코딩 오류: \(error.localizedDescription)"
    case .decoding(let error):
      return "데이터 파싱 오류: \(error.localizedDescription)"
    case .network(let error):
      return "네트워크 오류: \(error.localizedDescription)"
    case .http(let statusCode, let message):
      if message.isEmpty {
        return "HTTP 오류: \(statusCode)"
      }
      return "HTTP 오류 (\(statusCode)): \(message)"
    case .unauthorized:
      return "토큰이 만료되었습니다. 인증이 필요합니다."
    case .forbidden:
      return "접근이 금지되었습니다."
    case .notFound:
      return "요청한 리소스를 찾을 수 없습니다."
    }
  }
}
