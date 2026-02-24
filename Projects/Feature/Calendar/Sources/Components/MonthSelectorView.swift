import SwiftUI
import DoriCore

public struct MonthSelectorView: View {
  let currentMonth: Date
  let onPrevious: () -> Void
  let onNext: () -> Void

  public init(currentMonth: Date, onPrevious: @escaping () -> Void, onNext: @escaping () -> Void) {
    self.currentMonth = currentMonth
    self.onPrevious = onPrevious
    self.onNext = onNext
  }

  public var body: some View {
    HStack(spacing: 20) {
      Button {
        onPrevious()
      } label: {
        Image(systemName: "chevron.left")
          .font(.title3)
          .foregroundColor(.primary)
      }

      Text(currentMonth.koreanMonth)
        .font(.title2)
        .fontWeight(.semibold)

      Button {
        onNext()
      } label: {
        Image(systemName: "chevron.right")
          .font(.title3)
          .foregroundColor(.primary)
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
    onNext: {}
  )
}
