//
//  FontStyle.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/6/26.
//

import SwiftUI

// MARK: - Font 타입 속성을 정의하는 구조체
public enum FontType: Equatable {
  case system(Font.Weight)
  case custom(String)
}

// MARK: - TypoStyle 혹은 직접 활용도 가능하끔 구조 작성
@MainActor
public struct FontStyle {
  public let font: Font
  public let fontSize: CGFloat
  public let lineHeight: CGFloat
  public let lineSpacing: CGFloat
  
  public init(
    _ family: FontType = .system(.regular),
    size: CGFloat = 16
  ) {
    self.fontSize = size
    
    switch family {
    case .system(let weight):
      self.font = .system(size: size, weight: weight)
    case .custom(let fontName):
      // Bundle.module에서 폰트 등록 후 사용
      FontManager.registerFontIfNeeded(fontName)
      self.font = .custom(fontName, size: size)
    }
    // 등차수열 적용
    self.lineHeight = 2 * size - 6
    self.lineSpacing = lineHeight - fontSize
  }
}
