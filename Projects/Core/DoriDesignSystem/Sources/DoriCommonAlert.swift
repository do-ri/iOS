//
//  DoriCommonAlert.swift
//  DoriDesignSystem
//
//  Created by 강동영 on 2/13/26.
//

import SwiftUI

public struct DoriCommonAlert: View {
  @Binding var isPresented: Bool

  private let title: String
  private let description: String?
  private let secondaryButton: AlertButton?
  private let primaryButton: AlertButton

  public init(
    isPresented: Binding<Bool>,
    title: String,
    description: String? = nil,
    secondaryButton: AlertButton?,
    primaryButton: AlertButton
  ) {
    self._isPresented = isPresented
    self.title = title
    self.description = description
    self.secondaryButton = secondaryButton
    self.primaryButton = primaryButton
  }

  public var body: some View {
    ZStack {
      DoriColors.bgScrim.color
        .ignoresSafeArea()
        .onTapGesture {
          isPresented = false
          secondaryButton?.action()
        }

      VStack(spacing: 0) {
        contentArea
        buttonArea
      }
      .padding(16)
      .background(.bgPrimary)
      .cornerRadius(10)
      .padding(.horizontal, 24)
      .scaleEffect(isPresented ? 1.0 : 0.8)
      .opacity(isPresented ? 1.0 : 0.0)
      .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPresented)
    }
  }
  
  var contentArea: some View {
    VStack(alignment: .center, spacing: 8) {
      Text(title)
        .pretendard(.headline(.h1))
        .foregroundStyle(.textPrimary)
        .multilineTextAlignment(.center)
      
      if let description = description {
        Text(description)
          .pretendard(.body(.r4))
          .foregroundStyle(.textSecondary)
          .multilineTextAlignment(.center)
      }
    }
    .padding(.vertical, 40)
  }
  
  var buttonArea: some View {
    HStack(spacing: 10) {
      if let secondaryButton = secondaryButton {
        PrimaryButton(title: secondaryButton.title) {
          secondaryButton.action()
        }
        .backgroundColor(.bgSecondary)
        .foregroundColor(.textPrimary)
      }

      PrimaryButton(title: primaryButton.title) {
        primaryButton.action()
      }
    }
    .frame(maxHeight: 56)
  }
}

#Preview {
  DoriCommonAlert(
    isPresented: .constant(true),
    title: "로그아웃 하시겠습니까?",
    secondaryButton: AlertButton(.no) {
      print("no")
    },
    primaryButton: AlertButton(.yes) {
      print("yes")
    }
  )
}

#Preview {
  DoriCommonAlert(
    isPresented: .constant(true),
    title: "도리 알림을 켜면\n등록한 도리를 놓치지 않아요!",
    description: nil,
    secondaryButton: AlertButton(title: "나중에") {
    },
    primaryButton: AlertButton(title: "알림 켜기") {
    }
  )
}
