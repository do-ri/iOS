//
//  TotalAmountView.swift
//  DoriFeature
//
//  Created by 강동영 on 2/24/26.
//  Copyright © 2026 com.arex. All rights reserved.
//

import SwiftUI
import DoriCore
import DoriDesignSystem

struct CalendarTotalAmountView: View {
  private let selectedType: TransactionType
  private let totalAmount: Int
  
  init(
  _ selectedType: TransactionType,
  totalAmount: Int
  ) {
    self.selectedType = selectedType
    self.totalAmount = totalAmount
  }
  
  var body: some View {
    HStack(spacing: 0) {
      Text("총 \(selectedType.displayName)")
        .pretendard(.body(.m3))

      Spacer()

      AmountLabel(totalAmount)
        .pretendard(.body(.sb3))
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 11)
    .frame(maxWidth: .infinity)
    .frame(height: 46)
    .foregroundStyle(selectedType == .judori ? .doriWhite : .grey600)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(selectedType == .judori ? .secondary : .grey100)
    )
  }
}

#Preview {
  CalendarTotalAmountView(.judori, totalAmount: 2_500_000)
  CalendarTotalAmountView(.baddori, totalAmount: 2_500_000)
}
