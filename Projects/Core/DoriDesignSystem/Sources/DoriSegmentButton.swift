//
//  DoriSegmentButton.swift
//  DoriCore
//
//  Created by 강동영 on 2/23/26.
//  Copyright © 2026 com.arex. All rights reserved.
//

import SwiftUI

public struct DoriSegmentButton<ID: Hashable>: View {
  let option: DoriSegmentOption<ID>
  @Binding var selection: ID
  
  var isOn: Bool { selection == option.id }
  
  public var body: some View {
    PrimaryButton(title: option.title) {
      selection = option.id
    }
    .applyDoriSegmentStyle(isOn: isOn)
  }
}

fileprivate extension PrimaryButton {
  func applyDoriSegmentStyle(isOn: Bool) -> Self {
    isOn ? self.doriSelected() : self.doriUnselected()
  }
}

fileprivate extension PrimaryButton {
  func doriSelected() -> Self {
    self
      .pretendard(.body(.sb3))
      .backgroundColor(.brandMain)
      .foregroundColor(.onBrand)
      
  }
  
  func doriUnselected() -> Self {
    self
      .pretendard(.body(.r3))
      .backgroundColor(.bgPrimary)
      .foregroundColor(.textSecondary)
      .strokeColor(.borderInput)
  }
}
