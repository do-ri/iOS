//
//  CustomTabBar.swift
//  DoriApp
//
//  Created by 강동영 on 2/25/26.
//  Copyright © 2026 com.arex. All rights reserved.
//

import SwiftUI
import DoriDesignSystem

// MARK: - Custom TabBar

struct CustomTabBar: View {
  @Binding var selectedTab: MainTabFeature.State.Tab
  
  var body: some View {
    HStack(spacing: 0) {
      TabBarItem(
        icon: selectedTab == .calendar ? Image(.tabbarCalendarFill) : Image(.tabbarCalendar),
        title: "캘린더",
        isSelected: selectedTab == .calendar
      ) {
        selectedTab = .calendar
      }
      
      TabBarItem(
        icon: selectedTab == .history ? Image(.tabbarHistoryFill) : Image(.tabbarHistory),
        title: "내역",
        isSelected: selectedTab == .history
      ) {
        selectedTab = .history
      }
      
      TabBarItem(
        icon: selectedTab == .myPage ? Image(.tabbarMypageFill) : Image(.tabbarMypage),
        title: "마이홈",
        isSelected: selectedTab == .myPage
      ) {
        selectedTab = .myPage
      }
    }
    .background(.doriWhite)
    .shadow(
      color: .black.opacity(0.05),
      radius: 8,
      x: 0,
      y: -2
    )
  }
}

// MARK: - TabBarItem

private struct TabBarItem: View {
  let icon: Image
  let title: String
  let isSelected: Bool
  let action: () -> Void
  
  var font: TypoToken {
    isSelected ? .bold(.b11) : .regular(.r11)
  }
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        icon
          .renderingMode(.template)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 24, height: 24)
          .foregroundStyle(isSelected ? .main : .grey600)
        
        Text(title)
          .pretendard(font)
          .foregroundStyle(isSelected ? .main : .grey600)
      }
      .frame(maxWidth: .infinity)
      .contentShape(Rectangle())
    }
    .padding(.horizontal, 20)
    .padding(.top, 16)
    .buttonStyle(.plain)
  }
}
