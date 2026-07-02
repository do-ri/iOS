import SwiftUI
import DoriCore
import DoriDesignSystem

public struct MonthSelectorView: View {
  let currentMonth: Date
  let onPrevious: () -> Void
  let onNext: () -> Void
  let onMonthTapped: () -> Void

  public init(
    currentMonth: Date,
    onPrevious: @escaping () -> Void,
    onNext: @escaping () -> Void,
    onMonthTapped: @escaping () -> Void
  ) {
    self.currentMonth = currentMonth
    self.onPrevious = onPrevious
    self.onNext = onNext
    self.onMonthTapped = onMonthTapped
  }

  public var body: some View {
    HStack(spacing: 20) {
      Button {
        onPrevious()
      } label: {
        Image(systemName: "chevron.left")
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(.textPrimary)
      }

      Button {
        onMonthTapped()
      } label: {
        Text(currentMonth.koreanMonth)
          .pretendard(.body(.sb2))
          .foregroundStyle(.textPrimary)
      }

      Button {
        onNext()
      } label: {
        Image(systemName: "chevron.right")
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(.textPrimary)
      }
    }
    .padding(.horizontal)
    .padding(.vertical, 8)
  }
}

#Preview {
  MonthSelectorView(
    currentMonth: Date(),
    onPrevious: {},
    onNext: {},
    onMonthTapped: {}
  )
}
