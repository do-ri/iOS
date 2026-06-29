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
import FeatureNotification
import PlatformKakaoAuth
import PlatformKeychain
import PlatformFCM

@main
struct DoriApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
  let store: StoreOf<AppFeature>
  #if DEBUG
  private let debugLaunchRoute: DebugLaunchRoute?
  #endif

  init() {
    #if DEBUG
    self.debugLaunchRoute = DebugLaunchRoute(environment: ProcessInfo.processInfo.environment)
    #endif

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
      $0.fcmPushTestAPIClient = .live(networkService: networkService)
      $0.notificationSettingsAPIClient = .live(networkService: networkService)
      $0.notificationListAPIClient = .live(networkService: networkService)
    }

    storeBox.store = store
    self.store = store

    FontManager.registerAllFonts()
    KakaoSDKHandler.initializeFromMainBundle()

    FCMService.shared.tokenRefreshHandler = { token in
      try? tokenStore.saveFCMToken(token)
      let endpoint = RegisterFCMTokenEndpoint(token: token)
      _ = try? await networkService.request(
        endpoint,
        responseType: SuccessResponse<EmptyResponse>.self
      )
    }
  }

  var body: some Scene {
    WindowGroup {
      rootView
    }
  }

  @ViewBuilder
  private var rootView: some View {
    #if DEBUG
    if let debugLaunchRoute {
      debugLaunchRoute.makeView()
    } else {
      appView
    }
    #else
    appView
    #endif
  }

  private var appView: some View {
    AppView(store: store)
      .onOpenURL { url in
        _ = KakaoSDKHandler.handleOpenURL(url)
      }
      .task {
        await FCMService.shared.requestAuthorization()
      }
  }
}

#if DEBUG
private struct DebugLaunchRoute {
  private let environment: [String: String]
  private let route: String
  private let memo: String

  init?(environment: [String: String]) {
    guard let route = environment["DORI_DEBUG_ROUTE"] else { return nil }
    self.environment = environment
    self.route = route
    self.memo = environment["DORI_DEBUG_MEMO"] ?? ""
  }

  @MainActor
  @ViewBuilder
  func makeView() -> some View {
    switch route {
    case "addDoriPage3":
      NavigationStack {
        AddDoriView(
          store: Store(initialState: configuredState) {
            AddDoriFeature()
          } withDependencies: {
            $0.addDoriAPIClient = .testValue
            $0.userNotificationSettingsClient.isNotificationEnabled = {
              environment["DORI_DEBUG_NOTIFICATION_ENABLED"] == "true"
            }
          }
        )
      }
    default:
      EmptyView()
    }
  }

  @MainActor
  private var configuredState: AddDoriFeature.State {
    var state = AddDoriFeature.State()
    state.currentPage = 2
    state.searchQuery = environment["DORI_DEBUG_PARTNER_NAME"] ?? "김철수"
    state.amountInput.text = environment["DORI_DEBUG_AMOUNT"] ?? "100000"
    state.memo = memo
    return state
  }
}
#endif
