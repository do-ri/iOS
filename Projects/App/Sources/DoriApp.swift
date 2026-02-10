//
//  DoriApp.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/5/26.
//

import SwiftUI
import DoriDesignSystem

@main
struct DoriApp: App {
  
  init() {
    FontManager.registerAllFonts()
  }
  
  var body: some Scene {
    WindowGroup {
      MainTabView()
    }
  }
}
