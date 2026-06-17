import SwiftUI
import DoriDesignSystem
import DoriCore

public struct MonthPickerBottomSheet: View {
  let selectedDate: Date
  let onDateChanged: (Date) -> Void
  let onConfirm: () -> Void

  @State private var selectedYear: Int
  @State private var selectedMonth: Int

  private let years: [Int]
  private let months: [Int] = Array(1...12)

  public init(
    selectedDate: Date,
    onDateChanged: @escaping (Date) -> Void,
    onConfirm: @escaping () -> Void
  ) {
    self.selectedDate = selectedDate
    self.onDateChanged = onDateChanged
    self.onConfirm = onConfirm

    let currentYear = Calendar.current.component(.year, from: Date())
    _selectedYear = State(initialValue: selectedDate.year)
    _selectedMonth = State(initialValue: selectedDate.month)
    years = Array((currentYear - 5)...(currentYear + 5))
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Capsule()
        .fill(Color.gray.opacity(0.3))
        .frame(width: 36, height: 4)
        .frame(maxWidth: .infinity)
        .padding(.bottom, 20)

      Text("날짜를 선택하세요")
        .pretendard(.subtitle(.sb1))
        .foregroundStyle(.textPrimary)
        .padding(.horizontal, 20)
        .padding(.bottom, 32)

      HStack(spacing: 0) {
        Picker("년도", selection: $selectedYear) {
          ForEach(years, id: \.self) { year in
            Text(verbatim: "\(year)년").tag(year)
          }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)

        Picker("월", selection: $selectedMonth) {
          ForEach(months, id: \.self) { month in
            Text(verbatim: "\(month)월").tag(month)
          }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
      }
      .frame(height: 100)
      .padding(.bottom, 32)
      .onChange(of: selectedYear) { _, newYear in
        notifyDateChange(year: newYear, month: selectedMonth)
      }
      .onChange(of: selectedMonth) { _, newMonth in
        notifyDateChange(year: selectedYear, month: newMonth)
      }

      PrimaryButton(title: "완료") {
        onConfirm()
      }
      .padding(.horizontal, 16)
    }
    .background(.bgPrimary)
    .ignoresSafeArea(.container, edges: .bottom)
    .presentationDetents([.height(310)])
    .presentationBackground(UIAsset.Colors.bgPrimary.color)
    .presentationDragIndicator(.hidden)
    
  }

  private func notifyDateChange(year: Int, month: Int) {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = 1
    if let date = Calendar.current.date(from: components) {
      onDateChanged(date)
    }
  }
}
