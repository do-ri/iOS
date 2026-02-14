//
//  View+.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/6/26.
//

import SwiftUI

public extension View {
  // MARK: - font, linespacing 적용되어있음 (기본값: Pretendard)
  func pretendard(_ semantic: TypoSemantic) -> some View {
    let pretendardProvider = PretendardProvider()
    let fontStyle = semantic.getFontStyle(with: pretendardProvider)
    return self
      .font(fontStyle.font)
      .lineSpacing(fontStyle.lineSpacing)
  }
  
  func pretendard(_ token: TypoToken) -> some View {
    let pretendardProvider = PretendardProvider()
    let fontStyle = token.getFontStyle(with: pretendardProvider)
    return self
      .font(fontStyle.font)
      .lineSpacing(fontStyle.lineSpacing)
  }
  
  func hopangche(
    size: CGFloat,
    lineHeight: CGFloat = 55
  ) -> some View {
    let fontName = SamlipHopangProvider.FontName.basic.name
    let fontStyle = FontStyle(.custom(fontName), size: size)
    return self
      .font(fontStyle.font)
      .lineSpacing(fontStyle.lineSpacing)
  }
}
