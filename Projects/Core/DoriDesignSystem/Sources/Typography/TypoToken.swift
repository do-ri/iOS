//
//  TypoStyle.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/6/26.
//

import Foundation

@MainActor
public enum TypoStyle {
  case heading(TypoStyle.Heading)
  case subtitle(TypoStyle.SubTitle)
  case body(TypoStyle.Body)
  case caption(TypoStyle.Caption)
  
  // MARK: - 폰트에 의존하지 않는 스타일 정의
  private var styleSpec: (weight: FontWeight, size: CGFloat, lineHeight: CGFloat) {
    switch self {
    case .heading(let heading):
      return (.bold, heading.size, heading.lineHeight)
      
    case .subtitle(let subtitle):
      return (.semiBold, subtitle.size, subtitle.lineHeight)
      
    case .body(let body):
      return (.medium, body.size, body.lineHeight)
      
    case .caption(let caption):
      return (.regular, caption.size, caption.lineHeight)
    }
  }
  
  // MARK: - FontProvider를 받아서 FontStyle 생성
  public func getFontStyle(with provider: FontProvider) -> FontStyle {
    let spec = styleSpec
    let fontName = spec.weight.getFontName(from: provider)
    return FontStyle(.custom(fontName), size: spec.size)
  }
}

public extension TypoStyle {
  enum Heading: Int, CaseIterable {
    case h11 = 11, h13 = 13, h14 = 14, h15 = 15, h16 = 16, h20 = 20, h30 = 30
    
    var size: CGFloat { CGFloat(rawValue) }
    
    // 등차수열 적용
    var lineHeight: CGFloat { 2 * size - 6 }
  }
  
  enum SubTitle: Int, CaseIterable {
    case t12 = 12, t14 = 14, t15 = 15, t16 = 16, t20 = 20
    
    var size: CGFloat { CGFloat(rawValue) }
    
    // 등차수열 적용
    var lineHeight: CGFloat { 2 * size - 6 }
  }
  
  enum Body: Int, CaseIterable {
    case b11 = 11, b12, b13, b14, b15, b16
    
    var size: CGFloat { CGFloat(rawValue) }
    
    // 등차수열 적용
    var lineHeight: CGFloat { 2 * size - 6 }
  }
  
  enum Caption: Int, CaseIterable {
    case c11 = 11, c12, c13, c14, c15, c16, c18 = 18, c20 = 20
    
    var size: CGFloat { CGFloat(rawValue) }
    
    // 등차수열 적용
    var lineHeight: CGFloat { 2 * size - 6 }
  }
}
