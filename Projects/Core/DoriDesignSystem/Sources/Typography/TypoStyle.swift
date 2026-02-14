//
//  TypoStyle.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/6/26.
//

import Foundation

@MainActor
public enum TypoSemantic {
  case headline(TypoSemantic.Heading)
  case title(TypoSemantic.Title)
  case subtitle(TypoSemantic.SubTitle)
  case body(TypoSemantic.Body)
  case caption(TypoSemantic.Caption)
  
  // MARK: - 폰트에 의존하지 않는 스타일 정의
  private var styleSpec: FontSpec {
    
    switch self {
    case .headline(let headline):
      let spec = headline.token.getFontSpec()
      return .init(spec.weight, spec.size)
    case .title(let title):
      let spec = title.token.getFontSpec()
      return .init(spec.weight, spec.size)
    case .subtitle(let subtitle):
      let spec = subtitle.token.getFontSpec()
      return .init(spec.weight, spec.size)
    case .body(let body):
      let spec = body.token.getFontSpec()
      return .init(spec.weight, spec.size)
    case .caption(let caption):
      let spec = caption.token.getFontSpec()
      return .init(spec.weight, spec.size)
    }
  }
  
  // MARK: - FontProvider를 받아서 FontStyle 생성
  public func getFontStyle(with provider: FontProvider) -> FontStyle {
    let spec = styleSpec
    let fontName = spec.weight.getFontName(from: provider)
    return FontStyle(.custom(fontName), size: spec.size)
  }
}

public extension TypoSemantic {
  enum Heading: CaseIterable {
    case h1
    
    var token: TypoToken { TypoToken.bold(.b16) }
  }
  
  enum Title: CaseIterable {
    case t1
    
    var token: TypoToken { TypoToken.medium(.m16) }
  }
  
  enum SubTitle: CaseIterable {
    case sb1, sb2, m2
    
    var token: TypoToken {
      switch self {
      case .sb1:
          .semiBold(.sb20)
      case .sb2:
          .semiBold(.sb14)
      case .m2:
          .medium(.m14)
      }
    }
  }
  
  enum Body: CaseIterable {
    case b1, b4
    case sb2, sb3, sb6
    case m3, m5
    case r2, r3, r4, r6
    
    var token: TypoToken {
      switch self {
      case .b1:
          .bold(.b30)
      case .b4:
          .bold(.b14)
      case .sb2:
          .semiBold(.sb16)
      case .sb3:
          .semiBold(.sb15)
      case .sb6:
          .semiBold(.sb12)
      case .m3:
          .medium(.m15)
      case .m5:
          .medium(.m13)
      case .r2:
          .regular(.r16)
      case .r3:
          .regular(.r15)
      case .r4:
          .regular(.r14)
      case .r6:
          .regular(.r12)
      }
    }
  }
  
  enum Caption: CaseIterable {
    case b1, b2
    case m2
    case r1, r2
    
    var token: TypoToken {
      switch self {
      case .b1:
          .bold(.b13)
      case .b2:
          .bold(.b11)
      case .m2:
          .medium(.m11)
      case .r1:
          .regular(.r13)
      case .r2:
          .regular(.r11)
      }
    }
  }
}

@MainActor
public enum TypoToken {
  case bold(TypoToken.Bold)
  case semiBold(TypoToken.SemiBold)
  case medium(TypoToken.Medium)
  case regular(TypoToken.Regular)
  
  // MARK: - 폰트에 의존하지 않는 스타일 정의
  private var styleSpec: FontSpec {
    switch self {
    case .bold(let heading):
      return .init(.bold, heading.size)
      
    case .semiBold(let subtitle):
      return .init(.semiBold, subtitle.size)
      
    case .medium(let body):
      return .init(.medium, body.size)
      
    case .regular(let caption):
      return .init(.regular, caption.size)
    }
  }
  
  // MARK: - FontProvider를 받아서 FontStyle 생성
  public func getFontStyle(with provider: FontProvider) -> FontStyle {
    let spec = styleSpec
    let fontName = spec.weight.getFontName(from: provider)
    return FontStyle(.custom(fontName), size: spec.size)
  }
  
  public func getFontSpec() -> FontSpec {
    return styleSpec
  }
}

public struct FontSpec {
  let weight: FontWeight
  let size: CGFloat
  
  init(_ weight: FontWeight, _ size: CGFloat) {
    self.weight = weight
    self.size = size
  }
}

public extension TypoToken {
  enum Bold: Int, CaseIterable {
    case b11 = 11, b13 = 13, b14 = 14, b15 = 15, b16 = 16, b20 = 20, b30 = 30
    
    var size: CGFloat { CGFloat(rawValue) }
  }
  
  enum SemiBold: Int, CaseIterable {
    case sb12 = 12, sb14 = 14, sb15 = 15, sb16 = 16, sb20 = 20
    
    var size: CGFloat { CGFloat(rawValue) }
  }
  
  enum Medium: Int, CaseIterable {
    case m11 = 11, m12, m13, m14, m15, m16
    
    var size: CGFloat { CGFloat(rawValue) }
  }
  
  enum Regular: Int, CaseIterable {
    case r11 = 11, r12, r13, r14, r15, r16, r18 = 18, r20 = 20
    
    var size: CGFloat { CGFloat(rawValue) }
  }
}
