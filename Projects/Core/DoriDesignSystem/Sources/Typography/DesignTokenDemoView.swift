//
//  DesignTokenDemoView.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/6/26.
//

import SwiftUI

fileprivate struct DesignTokenDemoView: View {
  @State private var isColorSection = false
  
  var body: some View {
    ScrollView {
      if isColorSection { colorSection }
      else { typeSection }
    }
  }
  
  var colorSection: some View {
    VStack {
      ForEach(Self.brandColors, id: \.self) { color in
        VStack {
          Rectangle()
            .frame(height: 50)
            .foregroundStyle(color)
        }
      }
      
      ForEach(Self.greyColors, id: \.self) { color in
        VStack {
          Rectangle()
            .frame(height: 50)
            .foregroundStyle(color)
        }
      }
    }
    .padding()
  }
  
  var typeSection: some View {
    ScrollView {
      Section {
        ForEach(Self.typoHeadings, id: \.self) { heading in
          ZStack {
            Rectangle()
              .frame(height: 50)
              .foregroundStyle(.grey100)
            Text("도리 화이팅")
              .pretendard(.headline(heading))
          }
        }
      } header: {
        Text("헤딩")
          .padding()
          .pretendard(.bold(.b15))
          .foregroundStyle(.doriWhite)
          .frame(maxWidth: .infinity)
          .background(.secondary)
          .padding()
      }
      
      Section {
        ForEach(Self.typoSubTitles, id: \.self) { subtitle in
          ZStack {
            Rectangle()
              .frame(height: 50)
              .foregroundStyle(.grey200)
            Text("도리 화이팅")
              .pretendard(.subtitle(subtitle))
          }
        }
      } header: {
        Text("서브 타이틀")
          .padding()
          .pretendard(.bold(.b15))
          .foregroundStyle(.doriWhite)
          .frame(maxWidth: .infinity)
          .background(.secondary)
          .padding()
      }
      
      Section {
        ForEach(Self.typoBodys, id: \.self) { body in
          ZStack {
            Rectangle()
              .frame(height: 50)
              .foregroundStyle(.grey300)
            Text("도리 화이팅")
              .pretendard(.body(body))
          }
        }
      } header: {
        Text("바디")
          .padding()
          .pretendard(.bold(.b15))
          .foregroundStyle(.doriWhite)
          .frame(maxWidth: .infinity)
          .background(.main)
          .padding()
      }
      
      Section {
        ForEach(Self.typoCaptions, id: \.self) { caption in
          ZStack {
            Rectangle()
              .frame(height: 50)
              .foregroundStyle(.grey400)
            Text("도리 화이팅")
              .pretendard(.caption(caption))
          }
        }
      } header: {
        Text("캡션")
          .padding()
          .pretendard(.bold(.b15))
          .foregroundStyle(.doriWhite)
          .frame(maxWidth: .infinity)
          .background(.main)
          .padding()
      }
    }
  }
}

extension DesignTokenDemoView {
  private static let brandColors: [Color] = [
    DoriColors.main.color,
    DoriColors.secondary.color,
  ]
  
  private static let greyColors: [Color] = [
    DoriColors.doriWhite.color,
    DoriColors.grey100.color,
    DoriColors.grey200.color,
    DoriColors.grey300.color,
    DoriColors.grey400.color,
    DoriColors.grey500.color,
    DoriColors.grey600.color,
    DoriColors.grey700.color,
    DoriColors.grey800.color,
    DoriColors.doriBlack.color
  ]
  
  private static let typoHeadings: [TypoSemantic.Heading] = TypoSemantic.Heading.allCases
  private static let typoSubTitles: [TypoSemantic.SubTitle] = TypoSemantic.SubTitle.allCases
  private static let typoBodys: [TypoSemantic.Body] = TypoSemantic.Body.allCases
  private static let typoCaptions: [TypoSemantic.Caption] = TypoSemantic.Caption.allCases
}

#Preview {
  DesignTokenDemoView()
}
