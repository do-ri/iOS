//
//  FontProvider+Impl.swift
//  DoriCore
//
//  Created by 강동영 on 2/12/26.
//  Copyright © 2026 com.arex. All rights reserved.
//


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

// MARK: - SamlipHopang Font Provider
public enum SamlipHopangProvider: FontProvider {
  public var basic: String {
    FontName.basic.name
  }
  
  public var regular: String { basic }
  public var medium: String { basic }
  public var semiBold: String { basic }
  public var bold: String? { basic}
}

extension SamlipHopangProvider {
  enum FontName {
    case basic
    
    var name: String {
      return "SDSamliphopangcheTTFBasic"
    }
  }
}
