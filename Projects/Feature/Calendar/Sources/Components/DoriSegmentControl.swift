import SwiftUI
import DoriCore

public struct DoriSegmentControl: View {
  @Binding var selectedType: TransactionType
  private let items: [TransactionType]

  @Namespace private var indicatorNS

  public init(
    selectedType: Binding<TransactionType>,
    items: [TransactionType] = TransactionType.allCases
  ) {
    self._selectedType = selectedType
    self.items = items
  }

  public var body: some View {
    HStack(spacing: 0) {
      ForEach(items, id: \.self) { item in
        segmentButton(item)
      }
    }
    .padding(4) // 바깥 캡슐과 선택 캡슐 사이 여백
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(.bgSecondary)
    )
  }

  private func segmentButton(_ item: TransactionType) -> some View {
    Button {
      withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
        selectedType = item
      }
    } label: {
      ZStack {
        // 선택 인디케이터: "하나"만 존재하고 matchedGeometryEffect로 이동
        if selectedType == item {
          RoundedRectangle(cornerRadius: 10)
            .fill(selectedType == .judori ? .secondary : .grey600)
            .matchedGeometryEffect(id: "dori.segment.indicator", in: indicatorNS)
        }

        Text(item.displayName)
          .pretendard(selectedType == item ? .caption(.b1) : .body(.m5))
          .foregroundStyle(selectedType == item ? .doriWhite : .doriBlack)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 6)
          .padding(.horizontal, 10)
          .contentShape(Rectangle())
      }
    }
    .accessibilityLabel(Text(item.rawValue))
    .accessibilityAddTraits(selectedType == item ? .isSelected : [])
  }
}

#Preview {
  struct PreviewWrapper: View {
    @State private var selectedType: TransactionType = .judori
    
    var body: some View {
      VStack {
        Spacer()
        DoriSegmentControl(selectedType: $selectedType)
          .frame(width: 130,height: 32)
        
        Text("선택됨: \(selectedType.rawValue)")
        Spacer()
      }
    }
  }
  
  return PreviewWrapper()
}
