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
              .pretendard(.heading(heading))
          }
        }
      } header: {
        Text("헤딩")
          .padding()
          .pretendard(.heading(.h15))
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .background(.main200)
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
          .pretendard(.heading(.h15))
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .background(.main200)
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
          .pretendard(.heading(.h15))
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .background(.main200)
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
          .pretendard(.heading(.h15))
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .background(.main200)
          .padding()
      }
    }
  }
}

extension DesignTokenDemoView {
  private static let brandColors: [Color] = [
    Color.main100,
    Color.main200,
    Color.main300
  ]
  
  private static let greyColors: [Color] = [
    Color.white,
    Color.grey100,
    Color.grey200,
    Color.grey300,
    Color.grey400,
    Color.grey500,
    Color.grey600,
    Color.grey700,
    Color.grey800,
    Color.black
  ]
  
  private static let typoHeadings: [TypoStyle.Heading] = TypoStyle.Heading.allCases
  private static let typoSubTitles: [TypoStyle.SubTitle] = TypoStyle.SubTitle.allCases
  private static let typoBodys: [TypoStyle.Body] = TypoStyle.Body.allCases
  private static let typoCaptions: [TypoStyle.Caption] = TypoStyle.Caption.allCases
}

#Preview {
  DesignTokenDemoView()
}
