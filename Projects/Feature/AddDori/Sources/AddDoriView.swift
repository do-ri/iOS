//
//  AddDoriView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/15/26.
//

import SwiftUI
import ComposableArchitecture
import DoriDesignSystem

public struct AddDoriView: View {
  @Bindable var store: StoreOf<AddDoriFeature>
  @Environment(\.dismiss) private var dismiss
  @State private var isKeyboardVisible = false

  public init(store: StoreOf<AddDoriFeature>) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      VStack(spacing: 32) {
        pageIndicator

        pageContent
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
          .animation(
            .easeInOut(duration: 0.3),
            value: store.currentPage
          )
      }
      .background(.bgPrimary)
      .doriKeyboardDismissable()
      .doriNavigationBar(
        DoriNavigationBarConfig.backWithTitle(
          "내역 추가",
          onBack: {
            if store.currentPage == 0 {
              dismiss()
            } else {
              store.send(.previousPageTapped)
            }
          }
        )
      )
      .safeAreaInset(edge: .bottom, spacing: 0) {
        bottomCTA
      }
      .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
        isKeyboardVisible = true
      }
      .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
        isKeyboardVisible = false
      }
      .allowsHitTesting(!store.isDatePickerVisible)

      if store.isDatePickerVisible {
        DoriColors.bgScrim.color
          .ignoresSafeArea()
          .allowsHitTesting(false)

        Color.clear
          .ignoresSafeArea()
          .contentShape(Rectangle())
          .onTapGesture { store.send(.datePickerToggled) }

        AddDoriCalendarView(initialDate: store.eventDate) {
          store.send(.datePickerToggled)
        } selecionAction: { date in
          store.send(.eventDateChanged(date))
          store.send(.datePickerToggled)
        }
      }

      if store.isNotificationSettingsAlertPresented {
        DoriCommonAlert(
          isPresented: Binding(
            get: { store.isNotificationSettingsAlertPresented },
            set: { isPresented in
              if !isPresented {
                store.send(.notificationSettingsAlertDismissed)
              }
            }
          ),
          title: "도리 알림을 켜면\n등록한 도리를 놓치지 않아요!",
          description: nil,
          secondaryButton: AlertButton(title: "나중에") {
            store.send(.notificationSettingsAlertDismissed)
          },
          primaryButton: AlertButton(title: "알림 켜기") {
            openNotificationSettings()
            store.send(.notificationSettingsAlertDismissed)
          }
        )
      }
    }
  }

  @MainActor
  private func openNotificationSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
  }

  @ViewBuilder
  private var bottomCTA: some View {
    PrimaryButton(title: currentButtonTitle) {
      currentButtonAction()
    }
    .isEnable(isCurrentButtonEnabled)
    .padding(.horizontal, 16)
    .padding(.top, 12)
    .padding(.bottom, 20)
    .background(.bgPrimary)
  }

  private var currentButtonTitle: String {
    switch store.currentPage {
    case 0, 1:
      return "다음"
    case 2:
      return "완료"
    default:
      return "다음"
    }
  }

  private var isCurrentButtonEnabled: Bool {
    switch store.currentPage {
    case 0:
      return store.isPage1Valid
    case 1:
      return store.isPage2Valid
    case 2:
      return store.isPage3Valid
    default:
      return false
    }
  }

  private func currentButtonAction() {
    switch store.currentPage {
    case 0, 1:
      store.send(.nextPageTapped)
    case 2:
      store.send(.submitTapped)
    default:
      break
    }
  }
  
  private var pageIndicator: some View {
    HStack {
      PageIndicator(
        count: 3,
        currentIndex: Binding<Int?>(
          get: { store.currentPage },
          set: { _ in }
        )
      )
      .padding(.top, 24)
      .padding(.leading, 16)
      
      Spacer()
    }
  }
  
  @ViewBuilder
  private var pageContent: some View {
    switch store.currentPage {
    case 0:
      Page1NameTypeView(store: store)
        .transition(.asymmetric(
          insertion: .move(edge: .trailing),
          removal: .move(edge: .leading)
        ))
    case 1:
      Page2RelationEventView(store: store, isScrollEnabled: isKeyboardVisible)
        .transition(.asymmetric(
          insertion: .move(edge: .trailing),
          removal: .move(edge: .leading)
        ))
    case 2:
      Page3AmountDateView(store: store, isScrollEnabled: isKeyboardVisible)
        .transition(.asymmetric(
          insertion: .move(edge: .trailing),
          removal: .move(edge: .leading)
        ))
    default:
      EmptyView()
    }
  }
}

#Preview {
  NavigationStack {
    AddDoriView(
      store: Store(initialState: AddDoriFeature.State()) {
        AddDoriFeature()
      }
    )
  }
}
