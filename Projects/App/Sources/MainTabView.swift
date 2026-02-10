//
//  MainTabView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/5/26.
//

import SwiftUI

struct MainTabView: View {
  @State private var selectedTab = 0
  
  var body: some View {
    TabView(selection: $selectedTab) {
      Text("캘린더")
        .tabItem {
          Label("캘린더", systemImage: "calendar")
        }
        .tag(0)
      
      Text("내역")
        .tabItem {
          Label("내역", systemImage: "list.bullet.rectangle")
        }
        .tag(1)
      
      Text("마이페이지")
        .tabItem {
          Label("마이페이지", systemImage: "person.circle")
        }
        .tag(2)
    }
  }
}

#Preview {
  MainTabView()
}
