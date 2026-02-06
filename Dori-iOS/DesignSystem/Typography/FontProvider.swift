//
//  FontProvider.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/6/26.
//

import Foundation

// MARK: - Font Provider Protocol
public protocol FontProvider {
  var regular: String { get }
  var medium: String { get }
  var semiBold: String { get }
  var bold: String? { get }
}

// MARK: - Pretendard Font Provider
public struct PretendardProvider: FontProvider {
  public let regular: String = FontName.regular.name
  public let medium: String = FontName.medium.name
  public let semiBold: String = FontName.semiBold.name
  public let bold: String? = FontName.bold.name
  
  public init() {}
}

extension PretendardProvider {
  enum FontName {
    case regular, medium, semiBold, bold
    
    var name: String {
      switch self {
      case .regular: return "Pretendard-Regular"
      case .medium: return "Pretendard-Medium"
      case .semiBold: return "Pretendard-SemiBold"
      case .bold: return "Pretendard-Bold"
      }
    }
  }
}

// MARK: - Font Weight Enum
public enum FontWeight {
  case regular, medium, semiBold, bold
  
  public func getFontName(from provider: FontProvider) -> String {
    switch self {
    case .regular: return provider.regular
    case .medium: return provider.medium
    case .semiBold: return provider.semiBold
    case .bold: return provider.bold ?? provider.semiBold
    }
  }
}
