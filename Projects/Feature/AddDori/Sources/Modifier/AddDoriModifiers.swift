//
//  AddDoriModifiers.swift
//  DoriFeature
//
//  Created by 강동영 on 2/19/26.
//  Copyright © 2026 com.arex. All rights reserved.
//

import SwiftUI
import DoriDesignSystem

struct AddDoriSectionTitleStyleModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.pretendard(.subtitle(.m2)))
      .foregroundStyle(.grey600)
  }
}

struct RoundedStyleModifier: ViewModifier {
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

extension View {
  /// H padding: 16, V padding: 12, r: 10
  func roundedStyle() -> some View {
    modifier(RoundedStyleModifier())
  }
  
}

extension Text {
  func addDoriSectionTitleStyle() -> some View {
    modifier(AddDoriSectionTitleStyleModifier())
  }
}
