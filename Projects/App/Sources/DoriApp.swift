//
//  DoriApp.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import SwiftUI
import ComposableArchitecture
import DoriDesignSystem
import DoriNetwork
import DoriNetworkImpl
import FeatureMyPage
import FeatureOnboarding
import FeatureAddDori
import FeatureHistory
import PlatformKakaoAuth
import PlatformKeychain

@main
struct DoriApp: App {
  let store: StoreOf<AppFeature>

  init() {
    let tokenStore = KeychainAuthTokenStore(service: DoriKeychainKey.serviceID)
    let interceptor = AuthInterceptor(tokenStore: tokenStore)
    #if DEBUG
    let networkService = NetworkServiceImpl(
      configuration: .default,
      logger: NetworkLogger(),
      interceptor: interceptor
    )
    #else
    let networkService = NetworkServiceImpl(
      configuration: .default,
      logger: Logger(),
      interceptor: interceptor
    )
    #endif

    self.store = Store(initialState: AppFeature.State()) {
      AppFeature()
    } withDependencies: {
      $0.kakaoServerLoginClient = .live(
        networkService: networkService,
        tokenStore: tokenStore
      )
      
      $0.addDoriAPIClient = .live(networkService: networkService)

      $0.historyAPIClient = .live(networkService: networkService)

      $0.myPageAPIClient = .live(
        networkService: networkService,
        tokenStore: tokenStore
      )
    }

    FontManager.registerAllFonts()
    KakaoSDKHandler.initializeFromMainBundle()
  }

  var body: some Scene {
    WindowGroup {
      AppView(store: store)
        .onOpenURL { url in
          _ = KakaoSDKHandler.handleOpenURL(url)
        }
    }
  }
}
