//
//  DoriToggleSwitch.swift
//  Dori-iOS
//
//  Created by 강동영 on 3/19/26.
//

import DoriDesignSystem
import SwiftUI

struct DoriToggleSwitch: View {
  @Binding var isOn: Bool

  private let width: CGFloat = 26
  private let height: CGFloat = 15
  private let thumbSize: CGFloat = 13

  var body: some View {
    ZStack {
      Capsule()
        .fill(isOn ? UIAsset.Colors.main.color : UIAsset.Colors.grey300.color)
        .frame(width: width, height: height)
        .animation(.easeInOut(duration: 0.2), value: isOn)

      Circle()
        .fill(UIAsset.Colors.doriWhite.color)
        .frame(width: thumbSize, height: thumbSize)
        .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
        .offset(x: isOn ? (width / 2 - thumbSize / 2 - 2) : -(width / 2 - thumbSize / 2 - 2))
        .animation(.easeInOut(duration: 0.2), value: isOn)
    }
    .frame(width: width, height: height)
    .onTapGesture {
      isOn.toggle()
    }
  }
}

#Preview {
  @Previewable @State var isOn = false

  VStack(spacing: 24) {
    DoriToggleSwitch(isOn: $isOn)
    DoriToggleSwitch(isOn: .constant(true))
    DoriToggleSwitch(isOn: .constant(false))
  }
  .padding()
}
