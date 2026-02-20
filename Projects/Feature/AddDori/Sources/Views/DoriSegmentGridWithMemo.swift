//
//  DoriSegmentGridWithMemo.swift
//  DoriFeature
//
//  Created by 강동영 on 2/19/26.
//  Copyright © 2026 com.arex. All rights reserved.
//

import SwiftUI
import DoriDesignSystem
import DoriCore

struct DoriSegmentOption<ID: Hashable>: Identifiable {
  enum Role { case normal, other }
  
  let id: ID
  let title: String
  let role: Role
}

struct DoriSegmentGridWithMemo<ID: Hashable>: View {
  let options: [DoriSegmentOption<ID>]
  @Binding var selection: ID
  @Binding var memo: String
  
  private let columns: Int = 2
  private var otherID: ID? { options.first(where: { $0.role == .other })?.id }
  private var isOtherSelected: Bool { selection == otherID }
  
  init(
    options: [DoriSegmentOption<ID>],
    selection: Binding<ID>,
    memo: Binding<String> = .constant("")
  ) {
    self.options = options
    self._selection = selection
    self._memo = memo
  }
  
  var body: some View {
    VStack(spacing: 12) {
      grid
      if isOtherSelected { memoField }
    }
    .onChange(of: memo) { _, newValue in
      syncSelectionWithMemo(newValue)
    }
    .onChange(of: selection) { _, newSelection in
      syncMemoWithSelection(newSelection)
    }
  }
  
  private var grid: some View {
    Grid(horizontalSpacing: 16, verticalSpacing: 10) {
      ForEach(chunked(options, size: columns).indices, id: \.self) { row in
        let rowItems = chunked(options, size: columns)[row]
        
        GridRow {
          ForEach(rowItems) { option in
            DoriSegmentButton(option: option, selection: $selection)
          }
          
          // 만약 마지막 row가 1개만 있는 경우(스펙상 없다고 했지만) 빈칸 채우기
          if rowItems.count < columns {
            Color.clear
              .frame(maxWidth: .infinity, minHeight: 53)
          }
        }
      }
    }
  }
  
  private var memoField: some View {
    DoriTextField("관계를 입력하세요. (10자)", memo: $memo)
  }
  
  // memo가 있으면 other를 강제 선택
  private func syncSelectionWithMemo(_ memo: String) {
    let trimmed = memo.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }
    guard let otherID else { return }
    if selection != otherID {
      selection = otherID
    }
  }
  
  // other가 아닌 것을 선택하면 memo는 비움
  private func syncMemoWithSelection(_ selection: ID?) {
    guard let selection else { return }
    guard let otherID else { return }
    if selection != otherID, !memo.isEmpty {
      memo = ""
    }
  }
}

// helper
private func chunked<T>(_ array: [T], size: Int) -> [[T]] {
  guard size > 0 else { return [] }
  return stride(from: 0, to: array.count, by: size).map {
    Array(array[$0..<min($0 + size, array.count)])
  }
}

struct DoriSegmentButton<ID: Hashable>: View {
  let option: DoriSegmentOption<ID>
  @Binding var selection: ID
  
  var isOn: Bool { selection == option.id }
  
  var body: some View {
    PrimaryButton(title: option.title) {
      selection = option.id
    }
    .applyDoriSegmentStyle(isOn: isOn)
  }
}

fileprivate extension PrimaryButton {
  func applyDoriSegmentStyle(isOn: Bool) -> Self {
    isOn ? self.doriSelected() : self.doriUnselected()
  }
}

fileprivate extension PrimaryButton {
  func doriSelected() -> Self {
    self
      .pretendard(.body(.sb3))
      .backgroundColor(.main)
      .foregroundColor(.doriWhite)
      
  }
  
  func doriUnselected() -> Self {
    self
      .pretendard(.body(.r3))
      .backgroundColor(.doriWhite)
      .foregroundColor(.grey500)
      .strokeColor(.grey300)
  }
}

extension Relationship {
  func toSegmentOptions() -> DoriSegmentOption<Self> {
    if self == .other {
      DoriSegmentOption(id: self, title: self.rawValue, role: .other)
    } else {
      DoriSegmentOption(id: self, title: self.rawValue, role: .normal)
    }
  }
}

extension EventType {
  func toSegmentOptions() -> DoriSegmentOption<Self> {
    if self == .other {
      DoriSegmentOption(id: self, title: self.rawValue, role: .other)
    } else {
      DoriSegmentOption(id: self, title: self.rawValue, role: .normal)
    }
  }
}

extension Visited {
  func toSegmentOptions() -> DoriSegmentOption<Self> {
    DoriSegmentOption(id: self, title: self.rawValue, role: .normal)
  }
}

