//
//  DoriToastModifier.swift
//  DoriDesignSystem
//
//  Created by 강동영 on 2/13/26.
//

import SwiftUI

struct DoriToastModifier: ViewModifier {
  let toast: DoriToast?
  let alignment: Alignment
  let onDismiss: @MainActor () -> Void

  func body(content: Content) -> some View {
    content
      .overlay(alignment: alignment) {
        Group {
          if let toast {
            DoriToastView(toast: toast)
              .id(toast.id)
              .transition(
                .move(edge: alignment == .top ? .top : .bottom)
                .combined(with: .opacity)
              )
              .padding(
                alignment == .top ? .top : .bottom,
                8
              )
              .task(id: toast.id) {
                try? await Task.sleep(for: .seconds(toast.duration))
                guard !Task.isCancelled else { return }
                onDismiss()
              }
          }
        }
        .animation(
          .spring(
            response: 0.35,
            dampingFraction: 0.8
          ),
          value: toast
        )
      }
  }
}

public extension View {
  func doriToast(
    _ toast: DoriToast?,
    alignment: Alignment = .bottom,
    onDismiss: @escaping @MainActor () -> Void
  ) -> some View {
    modifier(
      DoriToastModifier(
        toast: toast,
        alignment: alignment,
        onDismiss: onDismiss
      )
    )
  }
}
