//
//  SplashView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//  Copyright © 2026 com.arex. All rights reserved.
//

import SwiftUI
import DoriDesignSystem
import DoriNetwork
import ComposableArchitecture

public struct SplashView: View {
  @Bindable var store: StoreOf<SplashFeature>
  
  public init(store: StoreOf<SplashFeature>) {
    self.store = store
    
  }
  private let prop: IntroProps = [IntroProps].onboarding[0]
  
  private let imageSize: CGFloat = 240
  public var body: some View {
    ZStack {
      DoriColors.bgPrimary.color
        .ignoresSafeArea()
      
      VStack(spacing: 40) {
        VStack(spacing: 0) {
          Text(prop.title)
            .hopangche(size: 55)
            .foregroundStyle(.brandMain)
          Text(prop.subtitle)
            .pretendard(.regular(.r18))
            .foregroundStyle(.brandMain)
        }
        
        prop.image.image
          .resizable()
          .frame(
            width: imageSize,
            height: imageSize
          )
        
        Spacer()
          .frame(height: imageSize/2)
      }
    }
    .onAppear {
      store.send(.isAppeared)
    }
    
  }
}

@Reducer
public struct SplashFeature : Sendable {
  public init() {}
  
  @ObservableState
  public struct State: Equatable, Sendable {
    public init() {}
  }
  
  public enum Action: Equatable, Sendable {
    case isAppeared
    case delegate(Delegate)
    
    public enum Delegate: Equatable, Sendable {
      case authenticated
      case unauthenticated
    }
  }

  @Dependency(AuthTokenStoreClient.self) var tokenStore

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .isAppeared:
      return .run { send in
        try await Task.sleep(for: .seconds(1.5))

        // 토큰 존재 여부만 체크 (서버가 만료 여부 판단)
        let hasToken = (try? tokenStore.exists()) ?? false

        if hasToken {
          // 바로 진입 → API 호출 시 401 발생하면 AuthInterceptor가 자동 refresh
          await send(.delegate(.authenticated))
        } else {
          await send(.delegate(.unauthenticated))
        }
      }

    case .delegate:
      return .none
    }
  }
}

#Preview {
  SplashView(store: Store(initialState: SplashFeature.State(), reducer: {
    SplashFeature()
  }))
}
