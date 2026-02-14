//
//  DoriToastView.swift
//  DoriDesignSystem
//
//  Created by 강동영 on 2/13/26.
//

import SwiftUI

@MainActor
public struct DoriToastView: View {
  private let toast: DoriToast

  public init(toast: DoriToast) {
    self.toast = toast
  }

  public var body: some View {
    HStack(spacing: 8) {
      if toast.type != .info {
        Image(systemName: toast.type.iconName)
          .foregroundStyle(toast.type.iconColor)
      }

      Text(toast.message)
        .pretendard(.regular(.r15))
        .foregroundStyle(.doriWhite)
        .lineLimit(2)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
    .frame(maxWidth: .infinity, alignment: .center)
    .background(toast.type.backgroundColor)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .shadow(
      color: .black.opacity(0.15),
      radius: 8,
      x: 0,
      y: 4
    )
    .padding(.horizontal, 20)
    .padding(.bottom, 50)
  }

  public static func == (
    lhs: DoriToastView,
    rhs: DoriToastView
  ) -> Bool {
    lhs.toast == rhs.toast
  }
}

extension ToastType {
  var iconName: String {
    switch self {
    case .success:
      return "checkmark.circle.fill"
    case .error:
      return "exclamationmark.circle.fill"
    case .info:
      return ""
    }
  }

  var iconColor: Color {
    switch self {
    case .success:
      return .white
    case .error:
      return .white
    case .info:
      return .white
    }
  }

  var backgroundColor: Color {
    switch self {
    case .success:
      return Color(
        red: 0.2,
        green: 0.7,
        blue: 0.4
      )
    case .error:
      return Color(
        red: 0.9,
        green: 0.3,
        blue: 0.3
      )
    case .info:
      return UIAsset.Colors.doriBlack.color.opacity(0.8)
    }
  }
}

#Preview("Toast Types") {
  @Previewable @State var toast: DoriToast? = nil

  VStack(spacing: 16) {
    Button("Success") {
      toast = DoriToast(
        type: .success,
        message: "로그아웃이 완료되었습니다."
      )
    }

    Button("Error") {
      toast = DoriToast(
        type: .error,
        message: "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
      )
    }

    Button("Info") {
      toast = DoriToast(
        type: .info,
        message: "새로운 거래가 등록되었습니다."
      )
    }
  }
  .frame(maxHeight: .infinity)
  .frame(maxWidth: .infinity)
  .background(Color(.white))
  .doriToast(toast) {
    toast = nil
  }
}
