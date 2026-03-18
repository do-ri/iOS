//
//  DoriExpandingTextView.swift
//  Dori-iOS
//
//  Created by 강동영 on 3/18/26.
//

import SwiftUI
import UIKit

public struct DoriExpandingTextView: View {
  @Binding var text: String
  @State private var dynamicHeight: CGFloat

  private let placeholder: String
  private let maxLength: Int
  private let minHeight: CGFloat

  public init(
    _ placeholder: String,
    text: Binding<String>,
    maxLength: Int = 40,
    minHeight: CGFloat = 46
  ) {
    self._text = text
    self.placeholder = placeholder
    self.maxLength = maxLength
    self.minHeight = minHeight
    self._dynamicHeight = State(initialValue: minHeight)
  }

  public var body: some View {
    ZStack(alignment: .topLeading) {
      RoundedRectangle(cornerRadius: 10)
        .fill(.doriWhite)

      RoundedRectangle(cornerRadius: 10)
        .stroke(.grey300, lineWidth: 1)

      ExpandingTextViewRepresentable(
        text: $text,
        dynamicHeight: $dynamicHeight,
        maxLength: maxLength,
        minHeight: minHeight
      )
      .frame(height: dynamicHeight)

      if text.isEmpty {
        Text(placeholder)
          .pretendard(.body(.r3))
          .foregroundStyle(.grey400)
          .padding(.horizontal, 16)
          .padding(.vertical, 13)
          .allowsHitTesting(false)
      }
    }
    .frame(minHeight: dynamicHeight)
    .accessibilityIdentifier("addDori.memoField")
  }
}

private struct ExpandingTextViewRepresentable: UIViewRepresentable {
  @Binding var text: String
  @Binding var dynamicHeight: CGFloat

  let maxLength: Int
  let minHeight: CGFloat

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()
    textView.delegate = context.coordinator
    textView.isScrollEnabled = false
    textView.backgroundColor = .clear
    textView.textContainerInset = .init(top: 12, left: 16, bottom: 12, right: 16)
    textView.textContainer.lineFragmentPadding = 0
    textView.font = UIFont(name: "Pretendard-Regular", size: 15) ?? .systemFont(ofSize: 15)
    textView.textColor = UIColor(DoriColors.doriBlack.color)
    textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    textView.accessibilityIdentifier = "addDori.memoTextView"
    return textView
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    if uiView.text != text {
      uiView.text = String(text.prefix(maxLength))
    }

    recalculateHeight(for: uiView)
  }

  private func recalculateHeight(for textView: UITextView) {
    let targetSize = CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
    let measuredHeight = max(textView.sizeThatFits(targetSize).height, minHeight)

    guard abs(dynamicHeight - measuredHeight) > 0.5 else { return }

    DispatchQueue.main.async {
      dynamicHeight = measuredHeight
    }
  }

  final class Coordinator: NSObject, UITextViewDelegate {
    private var parent: ExpandingTextViewRepresentable

    init(_ parent: ExpandingTextViewRepresentable) {
      self.parent = parent
    }

    func textViewDidChange(_ textView: UITextView) {
      let currentText = textView.text ?? ""

      if textView.markedTextRange == nil, currentText.count > parent.maxLength {
        let truncatedText = String(currentText.prefix(parent.maxLength))
        textView.text = truncatedText
        parent.text = truncatedText
      } else {
        parent.text = currentText
      }

      parent.recalculateHeight(for: textView)
    }
  }
}
