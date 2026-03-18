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
import FeatureCalendar
import PlatformKakaoAuth
import PlatformKeychain

@main
struct DoriApp: App {
  let store: StoreOf<AppFeature>

  init() {
    let tokenStore = KeychainAuthTokenStore(service: DoriKeychainKey.serviceID)

    // Store 참조를 위한 Box pattern
    final class StoreBox: @unchecked Sendable {
      var store: StoreOf<AppFeature>?
    }
    let storeBox = StoreBox()

    let interceptor = AuthInterceptor(tokenStore: tokenStore) { @MainActor in
      storeBox.store?.send(.forceLogout)
    }

    #if DEBUG
    let config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    config.urlCache = nil
    let networkService = NetworkServiceImpl(
      configuration: config,
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

    let store = Store(initialState: AppFeature.State()) {
      AppFeature()
    } withDependencies: {
      $0.authTokenStore = .live(tokenStore: tokenStore)
      $0.kakaoServerLoginClient = .live(
        networkService: networkService,
        tokenStore: tokenStore
      )

      $0.addDoriAPIClient = .live(networkService: networkService)
      $0.calendarClient = .live(networkService: networkService)
      $0.historyAPIClient = .live(networkService: networkService)
      $0.myPageAPIClient = .live(
        networkService: networkService,
        tokenStore: tokenStore
      )
    }

    storeBox.store = store
    self.store = store

    FontManager.registerAllFonts()
    KakaoSDKHandler.initializeFromMainBundle()
  }

  var body: some Scene {
    WindowGroup {
      AppView(store: store)
        .preferredColorScheme(.light)  // 다크모드 비활성화
        .onOpenURL { url in
          _ = KakaoSDKHandler.handleOpenURL(url)
        }
    }
  }
}
