import SwiftUI
import DoriDesignSystem

public struct DoriBarGraphView: View {
  let givenAmount: Int
  let receivedAmount: Int

  public init(givenAmount: Int, receivedAmount: Int) {
    self.givenAmount = givenAmount
    self.receivedAmount = receivedAmount
  }

  private var totalAmount: Int {
    givenAmount + receivedAmount
  }

  private var givenRatio: CGFloat {
    guard totalAmount > 0 else { return 0.5 }
    let divided = CGFloat(givenAmount) / CGFloat(totalAmount)
    // 이쁜 값 - 0.22
    guard divided > 0.1 else { return 0.22 }
    return divided
  }

  public var body: some View {
    GeometryReader { geometry in
      let width = geometry.size.width
      let dividerPosition = width * givenRatio

      ZStack(alignment: .leading) {
        // 배경
        RoundedRectangle(cornerRadius: 20)
          .fill(UIAsset.Colors.borderDefault.color)

        // 주도리 바 (왼쪽)
        if givenAmount > 0 {
          HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 20)
              .fill(UIAsset.Colors.secondary.color)
              .frame(width: dividerPosition)
            Spacer(minLength: 0)
          }
        }

        // 받도리 바 (오른쪽)
        if receivedAmount > 0 {
          HStack(spacing: 0) {
            Spacer(minLength: 0)
            RoundedRectangle(cornerRadius: 20)
              .fill(UIAsset.Colors.borderDefault.color)
              .frame(width: width - dividerPosition)
          }
        }

        // 아이콘들
        HStack {
          // 왼쪽 사람 아이콘 (주도리)
          if givenAmount > 0 {
            HStack(spacing: 3) {
              UIAsset.Icons.iconJudori.image
                .renderingMode(.template)
                .resizable()
                .frame(width: 26, height: 26)
                .padding(.leading, 4)
              Text("주도리")
                .pretendard(.body(.sb6))
            }
            .foregroundStyle(.onBrand)
          }

          Spacer()

          // 오른쪽 사람 아이콘 (받도리)
          if receivedAmount > 0 {
            HStack(spacing: 3) {
              Text("받도리")
                .pretendard(.body(.sb6))
              UIAsset.Icons.iconBaddori.image
                .renderingMode(.template)
                .resizable()
                .frame(width: 26, height: 26)
                .padding(.trailing, 4)
            }
            .foregroundStyle(.textSecondary)
          }
        }
      }
    }
    .frame(height: 34)
  }
}

#Preview {
  VStack(spacing: 20) {
    VStack(alignment: .leading) {
      Text("주도리 < 받도리")
      DoriBarGraphView(givenAmount: 1, receivedAmount: 100_000)
    }
    
    VStack(alignment: .leading) {
      Text("주도리 > 받도리")
      DoriBarGraphView(givenAmount: 300_000, receivedAmount: 100_000)
    }

    VStack(alignment: .leading) {
      Text("같은 금액")
      DoriBarGraphView(givenAmount: 50000, receivedAmount: 50000)
    }

    VStack(alignment: .leading) {
      Text("받도리만")
      DoriBarGraphView(givenAmount: 0, receivedAmount: 100000)
    }
    
    VStack(alignment: .leading) {
      Text("주도리만")
      DoriBarGraphView(givenAmount: 100000, receivedAmount: 0)
    }
    
  }
  .padding()
}
