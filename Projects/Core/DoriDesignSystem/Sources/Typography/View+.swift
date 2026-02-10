//
//  View+.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/6/26.
//

import SwiftUI

public extension View {
  // MARK: - font, linespacing 적용되어있음 (기본값: Pretendard)
  func pretendard(_ style: TypoStyle) -> some View {
    let pretendardProvider = PretendardProvider()
    let fontStyle = style.getFontStyle(with: pretendardProvider)
    return self
      .font(fontStyle.font)
      .lineSpacing(fontStyle.lineHeight)
  }
}
