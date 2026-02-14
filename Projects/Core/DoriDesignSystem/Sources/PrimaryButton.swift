//
//  PrimaryButton.swift
//  DoriDesignSystem
//
//  Created by 강동영 on 2/5/26.
//

import SwiftUI

public struct PrimaryButton: View {
  private let titleKey: String
  private let titleStyle: TypoSemantic
  private let action: @MainActor () -> Void
  
  private var foregroundColor: Color = UIAsset.Colors.doriWhite.color
  private var backgroundColor: Color = UIAsset.Colors.main.color
  private var cornerRadius: CGFloat = 10
  
  public var body: some View {
    Button {
      action()
    } label: {
      Text(titleKey)
        .pretendard(titleStyle)
        .foregroundStyle(foregroundColor)
        .frame(maxWidth: .infinity, maxHeight: 53)
        .background(
          RoundedRectangle(cornerRadius: cornerRadius)
            .fill(backgroundColor)
        )
    }
  }
  
  public init(
    title: String,
    style: TypoSemantic = .body(.sb3),
    action: @escaping @MainActor () -> Void = {}
  ) {
    self.titleKey = title
    self.titleStyle = style
    self.action = action
  }
}

public extension PrimaryButton {
  func foregroundColor(_ color: Color) -> Self {
    var button = self
    button.foregroundColor = color
    return button
  }
  
  func foregroundColor(_ asset: UIAsset.Colors) -> Self {
    var button = self
    button.foregroundColor = asset.color
    return button
  }
  
  func backgroundColor(_ color: Color) -> Self {
    var button = self
    button.backgroundColor = color
    return button
  }
  
  func backgroundColor(_ asset: UIAsset.Colors) -> Self {
    var button = self
    button.backgroundColor = asset.color
    return button
  }
  
  func cornerRadius(_ value: CGFloat) -> Self {
    var button = self
    button.cornerRadius = value
    return button
  }
}
