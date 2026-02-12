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
