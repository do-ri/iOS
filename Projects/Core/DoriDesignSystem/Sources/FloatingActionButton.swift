//
//  FloatingActionButton.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/15/26.
//

import SwiftUI

public struct FloatingActionButton: View {
  let action: () -> Void

  public init(action: @escaping () -> Void) {
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      Image(systemName: "plus")
        .font(.title2)
        .fontWeight(.semibold)
        .foregroundStyle(.bgPrimary)
        .frame(
          width: 56,
          height: 56
        )
        .background(DoriColors.brandMain.color)
        .clipShape(Circle())
        .shadow(
          color: .black.opacity(0.3),
          radius: 4,
          x: 0,
          y: 2
        )
    }
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2)
      .ignoresSafeArea()

    VStack {
      Spacer()
      HStack {
        Spacer()
        FloatingActionButton {
          print("FAB tapped")
        }
        .padding()
      }
    }
  }
}
