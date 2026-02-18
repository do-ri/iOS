//
//  AmountLabel.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/18/26.
//

import SwiftUI
import DoriCore

public struct AmountLabel: View {
  let amount: Int

  public init(_ amount: Int) {
    self.amount = amount
  }

  public var body: some View {
    Text(amount.wonFormatted)
  }
}
