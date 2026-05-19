//
//  PageIndicator.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/15/26.
//

import SwiftUI

public struct PageIndicator: View {
  let count: Int
  @Binding var currentIndex: Int?

  public init(
    count: Int,
    currentIndex: Binding<Int?>
  ) {
    self.count = count
    if currentIndex.wrappedValue == nil {
      self._currentIndex = .constant(0)
    } else {
      self._currentIndex = currentIndex
    }
  }

  public var body: some View {
    HStack {
      ForEach(0..<count, id: \.self) { index in
        Circle()
          .frame(
            width: 10,
            height: 10
          )
          .foregroundStyle(
            currentIndex == index
            ? DoriColors.brandMain.color
            : DoriColors.borderDefault.color
          )
      }
    }
  }
}
