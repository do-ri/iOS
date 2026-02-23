//
//  DoriTextField.swift
//  DoriFeature
//
//  Created by 강동영 on 2/19/26.
//  Copyright © 2026 com.arex. All rights reserved.
//

import SwiftUI

public struct DoriTextField: View {
  @Binding var memo: String
  
  private let placeholder: String
  private let maxLength: Int
  
  public init(
    _ placeholder: String,
    memo: Binding<String>,
    maxLength: Int = 10
  ) {
    self._memo = memo
    self.placeholder = placeholder
    self.maxLength = maxLength
  }
  
  public var body: some View {
    ZStack(alignment: .center) {
      RoundedRectangle(cornerRadius: 10)
        .stroke(.grey300, lineWidth: 1)
      
      RoundedRectangle(cornerRadius: 10)
        .fill(.doriWhite)
      
      TextField(
        placeholder,
        text: Binding(
          get: { memo },
          set: { memo = String($0.prefix(maxLength)) }
        )
      )
      .pretendard(.body(.r3))
      .padding(.horizontal, 16)

    }
    .frame(height: 46)
  }
}

#Preview {
  @Previewable @State var memo: String = ""
  
  DoriTextField("plz text", memo: $memo)
}
