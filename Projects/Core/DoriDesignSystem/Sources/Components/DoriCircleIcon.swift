//
//  DoriCircleIcon.swift
//  Dori-iOS
//
//  Created by 강동영 on 6/23/26.
//

import SwiftUI

/// 주도리/받도리 아이콘을 원형 배경 배지로 렌더한다.
/// path 는 템플릿으로 틴팅되고, 전경/배경 색은 모두 semantic 토큰을 경유하므로 다크모드가 자동 적응한다.
public struct DoriCircleIcon: View {
  public enum Style {
    case judori
    case baddori

    var foreground: Color {
      switch self {
      case .judori:  return UIAsset.Colors.onBrand.color       // white / black
      case .baddori: return UIAsset.Colors.textSecondary.color // #6B7684 / #A0A0A0
      }
    }

    var background: Color {
      switch self {
      case .judori:  return UIAsset.Colors.brandMain.color     // #20346F / #6C8FF0
      case .baddori: return UIAsset.Colors.borderDefault.color // #E5E8EB / #2E2E2E
      }
    }
  }

  private let icon: UIAsset.Icons
  private let style: Style
  private let diameter: CGFloat = 34
  private let iconSize: CGFloat = 26

  public init(_ icon: UIAsset.Icons, style: Style) {
    self.icon = icon
    self.style = style
  }

  public var body: some View {
    icon.image
      .renderingMode(.template)
      .resizable()
      .scaledToFit()
      .frame(width: iconSize, height: iconSize)
      .foregroundStyle(style.foreground)
      .frame(width: diameter, height: diameter)
      .background(Circle().fill(style.background))
  }
}

#Preview {
  HStack(spacing: 16) {
    DoriCircleIcon(.judoriWedding, style: .judori)
    DoriCircleIcon(.baddoriWedding, style: .baddori)
    DoriCircleIcon(.judoriEtc, style: .judori)
    DoriCircleIcon(.baddoriEtc, style: .baddori)
  }
  .padding()
}
