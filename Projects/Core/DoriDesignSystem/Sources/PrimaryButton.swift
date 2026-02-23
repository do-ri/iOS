//
//  PrimaryButton.swift
//  DoriDesignSystem
//
//  Created by 강동영 on 2/5/26.
//

import SwiftUI

public struct PrimaryButton: View {
  private let titleKey: String
  private var titleStyle: TypoSemantic
  private let action: @MainActor () -> Void
  private var isEnabled: Bool = true
  
  private var foregroundColor: Color = UIAsset.Colors.doriWhite.color
  private var backgroundColor: Color = UIAsset.Colors.main.color
  private var strokeColor: Color? = nil
  private var cornerRadius: CGFloat = 10
  
  public var body: some View {
    Button {
      guard isEnabled else { return }
      action()
    } label: {
      Text(titleKey)
        .pretendard(titleStyle)
        .foregroundStyle(foregroundColor)
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .background(
          RoundedRectangle(cornerRadius: cornerRadius)
            .fill(backgroundColor)
            .stroke(strokeColor ?? .clear, style: .init(lineWidth: 1))
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
  func pretendard(_ semantic: TypoSemantic) -> Self {
    var button = self
    button.titleStyle = semantic
    return button
  }
  
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
  
  func strokeColor(_ asset: UIAsset.Colors) -> Self {
    var button = self
    button.strokeColor = asset.color
    return button
  }
  
  func isEnable(_ isEnable: Bool) -> some View {
    print("isEnable: \(isEnable)")
    var button = self
    let backgroundColor = isEnable ? UIAsset.Colors.main.color : UIAsset.Colors.grey100.color
    let foregroundColor = isEnable ? UIAsset.Colors.doriWhite.color : UIAsset.Colors.grey500.color
    
    button.backgroundColor = backgroundColor
    button.foregroundColor = foregroundColor
    button.isEnabled = isEnable
    
    return button
      .disabled(!isEnable)
  }
  
}
