//
//  DoriEmptyView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/23/26.
//

import SwiftUI

public struct DoriEmptyView: View {

  public struct Content: Sendable {
    public let image: Image
    public let title: String
    public let description: String

    public init(
      image: Image,
      title: String,
      description: String
    ) {
      self.image = image
      self.title = title
      self.description = description
    }
  }

  private let content: Content

  public init(_ content: Content) {
    self.content = content
  }

  public var body: some View {
    ContentUnavailableView {
      Label {
        Text(content.title)
          .pretendard(.headline(.h1))
          .foregroundStyle(.doriBlack)
      } icon: {
        content.image
          .resizable()
          .frame(width: 200, height: 200)
      }
    } description: {
      Text(content.description)
        .pretendard(.body(.r4))
        .foregroundStyle(.grey600)
    }
  }
}

// MARK: - Predefined Content

public extension DoriEmptyView.Content {

  /// 파트너 목록이 없을 때
  static let partnerList = DoriEmptyView.Content(
    image: UIAsset.Images.placeholderEmpty.image,
    title: "아직 주고받은 도리가 없어요",
    description: "마음을 주고받은 순간들을 기록해보세요!"
  )

  /// 특정 파트너의 도리 내역이 없을 때
  static let doriHistory = DoriEmptyView.Content(
    image: UIAsset.Images.plcaeholderSearch.image,
    title: "검색된 도리가 없어요.",
    description: "해당 도리의 기록을 찾을 수 없어요.\n다른 이름으로 검색해보세요."
  )
}

// MARK: - Preview

#Preview("파트너 목록 없음") {
  DoriEmptyView(.partnerList)
}

#Preview("도리 내역 없음") {
  DoriEmptyView(.doriHistory)
}
