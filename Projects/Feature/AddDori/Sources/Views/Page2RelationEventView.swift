//
//  Page2RelationEventView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/15/26.
//

import SwiftUI
import ComposableArchitecture
import DoriDesignSystem
import DoriCore

struct Page2RelationEventView: View {
  @Bindable var store: StoreOf<AddDoriFeature>

  @State private var memo: String = ""
  
  private let options2x2: [DoriSegmentOption<Relationship>] = Relationship.allCases.map { $0.toSegmentOptions() }
  
  private let options3x2: [DoriSegmentOption<EventType>] = EventType.allCases.map { $0.toSegmentOptions() }
  
  var body: some View {
    VStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 32) {
        // 관계
        VStack(alignment: .leading, spacing: 12) {
          Text("관계")
            .addDoriSectionTitleStyle()
          
          DoriSegmentGridWithMemo(
            options: options2x2,
            selection: $store.selectedRelationship.sending(\.relationshipSelected),
            memo: $store.customRelationship.sending(\.customRelationshipChanged)
          )
        }
        
        // 경조사
        VStack(alignment: .leading, spacing: 12) {
          Text("경조사")
            .addDoriSectionTitleStyle()
          
          DoriSegmentGridWithMemo(
            options: options3x2,
            selection: $store.selectedEventType.sending(\.eventTypeSelected),
            memo: $store.customEventType.sending(\.customEventTypeChanged),
            memoPlaceholder: "경조사를 입력하세요. (10자)"
          )
        }
      }
      
      Spacer()
      
      // 다음 버튼
      PrimaryButton(title: "다음") {
        store.send(.nextPageTapped)
      }
      .isEnable(store.isPage2Valid)
    }
    .padding(.horizontal, 16)
    .padding(.bottom, 20)
  }
  
}

#Preview {
  Page2RelationEventView(
    store: Store(initialState: AddDoriFeature.State()) {
      AddDoriFeature()
    }
  )
}
