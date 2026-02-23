import SwiftUI
import DoriDesignSystem

public struct DateHeaderView: View {
  private let date: Date
  
  public init(date: Date) {
    self.date = date
  }
  
  public var body: some View {
    Text(date.koreanDateWithWeekday)
      .pretendard(.medium(.m12))
      .foregroundStyle(.grey600)
  }
}

#Preview {
  DateHeaderView(date: Date())
}
