import SwiftUI

@testable import DoriDesignSystem

struct ColorSwatchSheet: View {
  private let tokens: [(name: String, color: UIAsset.Colors)] = [
    ("bgPrimary", .bgPrimary),
    ("bgSecondary", .bgSecondary),
    ("bgScrim", .bgScrim),
    ("textPrimary", .textPrimary),
    ("textSecondary", .textSecondary),
    ("textDisabled", .textDisabled),
    ("textPlaceholder", .textPlaceholder),
    ("borderDefault", .borderDefault),
    ("borderInput", .borderInput),
    ("brandMain", .brandMain),
    ("onBrand", .onBrand),
    ("feedbackTextError", .feedbackTextError),
  ]

  var body: some View {
    VStack(spacing: 0) {
      ForEach(tokens, id: \.name) { token in
        HStack(spacing: 12) {
          ZStack {
            Rectangle()
              .fill(token.color.color)
            Rectangle()
              .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
          }
          .frame(width: 64, height: 32)

          Text(token.name)
            .font(.system(size: 13, design: .monospaced))
            .foregroundStyle(.textPrimary)

          Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
      }
    }
    .padding(.vertical, 16)
    .frame(width: 320)
    .background(UIAsset.Colors.bgPrimary.color)
  }
}
