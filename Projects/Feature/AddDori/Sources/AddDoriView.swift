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

  public init(store: StoreOf<AddDoriFeature>) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      VStack(spacing: 32) {
        pageIndicator

        pageContent
          .animation(
            .easeInOut(duration: 0.3),
            value: store.currentPage
          )
      }
      .background(.doriWhite)
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
      .allowsHitTesting(!store.isDatePickerVisible)

      if store.isDatePickerVisible {
        Color.black.opacity(0.4)
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
      Page2RelationEventView(store: store)
        .transition(.asymmetric(
          insertion: .move(edge: .trailing),
          removal: .move(edge: .leading)
        ))
    case 2:
      Page3AmountDateView(store: store)
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
