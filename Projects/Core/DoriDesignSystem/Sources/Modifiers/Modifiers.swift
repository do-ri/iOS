//
//  Modifiers.swift
//  DoriCore
//
//  Created by 강동영 on 2/23/26.
//  Copyright © 2026 com.arex. All rights reserved.
//

import SwiftUI

struct AddDoriSectionTitleStyleModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .pretendard(.subtitle(.m2))
      .foregroundStyle(.grey600)
  }
}

public extension Text {
  func addDoriSectionTitleStyle() -> some View {
    modifier(AddDoriSectionTitleStyleModifier())
  }
}

struct RoundedBorderModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(
        RoundedRectangle(cornerRadius: 10)
          .stroke(DoriColors.grey300.color)
      )
  }
}

public extension View {
  /// H padding: 16, V padding: 12, r: 10, grey300 border
  func roundedStyle() -> some View {
    modifier(RoundedBorderModifier())
  }
}
