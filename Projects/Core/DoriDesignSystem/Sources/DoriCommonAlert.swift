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
      Color.black.opacity(0.4)
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
      .background(.doriWhite)
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
        .foregroundStyle(.doriBlack)
      
      if let description = description {
        Text(description)
          .pretendard(.body(.r4))
          .foregroundStyle(.grey600)
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
        .backgroundColor(.grey100)
        .foregroundColor(.black)
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
    title: "회원탈퇴",
    description: "정말 도리를 탈퇴하실건가요?\n재가입 시에도 이용 내역은 복구되지 않습니다.",
    secondaryButton: AlertButton(.no) {
    },
    primaryButton: AlertButton(.yes) {
    }
  )
}
