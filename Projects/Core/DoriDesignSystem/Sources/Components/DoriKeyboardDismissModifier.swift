//
//  DoriKeyboardDismissModifier.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/27/26.
//

import SwiftUI

/// 빈 영역 탭으로 키보드를 dismiss하는 ViewModifier
///
/// numberPad 등 Return 키가 없는 키보드 타입에서 특히 유용합니다.
/// `.contentShape(Rectangle())`를 사용하여 빈 영역(Spacer 등)도 탭 인식이 가능합니다.
///
/// ## 사용법
/// ```swift
/// VStack {
///   TextField("금액", text: $amount)
///     .keyboardType(.numberPad)
///   Spacer()
/// }
/// .doriKeyboardDismissable()  // 빈 영역 탭 시 키보드 dismiss
/// ```
///
/// ## 주의사항
/// - 버튼이나 리스트 아이템 등 더 구체적인 gesture가 있는 경우, 해당 gesture가 우선 처리됩니다.
/// - overlay나 sheet 등의 상위 레이어와는 충돌하지 않습니다.
public struct DoriKeyboardDismissModifier: ViewModifier {
  public func body(content: Content) -> some View {
    content
      .contentShape(Rectangle())  // 빈 영역도 탭 인식
      .simultaneousGesture(
        TapGesture().onEnded {
          UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
          )
        }
      )
  }
}

public extension View {
  /// 빈 영역 탭으로 키보드를 dismiss할 수 있게 만듭니다.
  ///
  /// numberPad 등 Return 키가 없는 키보드에서 유용합니다.
  func doriKeyboardDismissable() -> some View {
    modifier(DoriKeyboardDismissModifier())
  }
}
