//
//  DoriSegmentGridWithMemo.swift
//  DoriCore
//
//  Created by 강동영 on 2/23/26.
//  Copyright © 2026 com.arex. All rights reserved.
//

import SwiftUI

public struct DoriSegmentGridWithMemo<ID: Hashable>: View {
  let options: [DoriSegmentOption<ID>]
  @Binding var selection: ID
  @Binding var memo: String
  private let memoPlaceholder: String

  private let columns: Int = 2
  private var otherID: ID? { options.first(where: { $0.role == .other })?.id }
  private var isOtherSelected: Bool { selection == otherID }

  public init(
    options: [DoriSegmentOption<ID>],
    selection: Binding<ID>,
    memo: Binding<String> = .constant(""),
    memoPlaceholder: String = "관계를 입력하세요. (10자)"
  ) {
    self.options = options
    self._selection = selection
    self._memo = memo
    self.memoPlaceholder = memoPlaceholder
  }
  
  public var body: some View {
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
    DoriTextField(memoPlaceholder, memo: $memo)
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
