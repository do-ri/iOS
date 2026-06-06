//
//  IntroView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/11/26.
//

import SwiftUI
import DoriDesignSystem
import ComposableArchitecture

struct IntroProps: Identifiable {
  let id: Int
  let title: String
  let subtitle: String
  let image: DoriImages
}

extension [IntroProps] {
  nonisolated(unsafe) static let onboarding: [IntroProps] = [
    .init(
      id: 0,
      title: "도리",
      subtitle: "돈보다 깊은 마음, 도리로 남다",
      image: .onboarding0
    ),
    .init(
      id: 1,
      title: "주고 받은 도리를",
      subtitle: "그래프로 확인해보세요",
      image: .onboarding1
    ),
    .init(
      id: 2,
      title: "누구와 주고 받았는지",
      subtitle: "상세 내역도 확인 가능해요",
      image: .onboarding2
    ),
    .init(
      id: 3,
      title: "캘린더를 통해",
      subtitle: "도리 내역을 한눈에 볼 수 있어요",
      image: .onboarding3
    ),
  ]
}

public struct IntroView: View {
  @Bindable var store: StoreOf<IntroFeature>
  
  public init(store: StoreOf<IntroFeature>) {
    self.store = store
  }
  
  @State private var currentIndex: Int? = nil
  
  private let props: [IntroProps] = .onboarding
  public var body: some View {
    ZStack {
      DoriColors.bgPrimary.color
        .ignoresSafeArea()
      
      VStack(spacing: 0) {
        Spacer()
        
        onbordingView
          .overlay(alignment: .bottom) {
            PageIndicator(
              count: props.count,
              currentIndex: $currentIndex
            )
            .offset(y: 30)
          }
        Spacer()
        
        kakaoLoginButton
      }
      .alert(
        "카카오 로그인 실패",
        isPresented: Binding(
          get: { store.errorMessage != nil },
          set: { isPresented in
            if !isPresented {
              store.send(.errorAlertDismissed)
            }
          }
        )
      ) {
        Button("확인", role: .cancel) {}
      } message: {
        Text(store.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
      }
    }
  }
  
  var onbordingView: some View {
    ScrollView(.horizontal) {
      LazyHStack(alignment:.bottom, spacing: 0) {
        ForEach(props) { prop in
          VStack(spacing: 40) {
            
            VStack(spacing: 0) {
              if prop.id == 0 {
                Text(prop.title)
                  .hopangche(size: 55)
                  .foregroundStyle(.brandMain)
                Text(prop.subtitle)
                  .pretendard(.regular(.r18))
                  .foregroundStyle(.brandMain)
              } else {
                Text(prop.title)
                  .pretendard(.subtitle(.sb1))
                  .foregroundStyle(.brandMain)
                Text(prop.subtitle)
                  .pretendard(.subtitle(.sb1))
                  .foregroundStyle(.brandMain)
              }
              
            }
            
            prop.image.image
              .resizable()
              .frame(
                width: 240,
                height: 240
              )
          }
          .containerRelativeFrame([.horizontal])
          .tag(prop.id)
        }
      }
      .scrollTargetLayout()
    }
    .frame(height: 350)
    .padding(.horizontal, 60)
    .scrollTargetBehavior(.paging)
    .scrollPosition(id: $currentIndex)
  }
  
  var kakaoLoginButton: some View {
    Button {
      store.send(.kakaoLoginButtonTapped)
    } label: {
      Text("카카오로 시작하기")
        .pretendard(.semiBold(.sb15))
        .foregroundStyle(DoriColors.kakaoOnYellow.color)
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .background(
          RoundedRectangle(cornerRadius: 10)
            .foregroundStyle(.yellow)
        )
        .overlay() {
          HStack {
            DoriIcons.iconKakaoLogin.image
              .resizable()
              .frame(
                width: 24,
                height: 24
              )
              .padding(.leading, 16)
            
            Spacer()
          }
          
        }
    }
    .disabled(store.isLoading)
    .padding()
  }
}


#Preview {
  IntroView(
    store: Store(initialState: IntroFeature.State()) {
      IntroFeature()
    }
  )
}
