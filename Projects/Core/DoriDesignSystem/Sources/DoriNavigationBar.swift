//
//  DoriNavigationBar.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/26/26.
//

import SwiftUI

// MARK: - Configuration

public struct DoriNavigationBarConfig {
  public let leading: LeadingItem
  public let center: CenterItem
  public let trailing: [TrailingItem]

  public init(
    leading: LeadingItem,
    center: CenterItem,
    trailing: [TrailingItem]
  ) {
    self.leading = leading
    self.center = center
    self.trailing = trailing
  }

  public enum LeadingItem {
    case none
    case backButton(action: @MainActor () -> Void)
  }

  public enum CenterItem {
    case none
    case title(String)
    case searchField(text: Binding<String>, placeholder: String, onClear: (@MainActor () -> Void)? = nil)
  }

  public enum TrailingItem {
    case iconButton(image: Image, action: @MainActor () -> Void)
  }

  // MARK: - Factory Methods

  /// Case 0: leading X, title X
  public static var empty: DoriNavigationBarConfig {
    DoriNavigationBarConfig(
      leading: .none,
      center: .none,
      trailing: []
    )
  }

  /// Case 1: back + title
  public static func backWithTitle(
    _ title: String,
    onBack: @escaping @MainActor () -> Void
  ) -> DoriNavigationBarConfig {
    DoriNavigationBarConfig(
      leading: .backButton(action: onBack),
      center: .title(title),
      trailing: []
    )
  }

  /// Case 2: back + title + trailing items (최대 2개)
  public static func backWithTitleAndActions(
    _ title: String,
    onBack: @escaping @MainActor () -> Void,
    trailing: [TrailingItem]
  ) -> DoriNavigationBarConfig {
    DoriNavigationBarConfig(
      leading: .backButton(action: onBack),
      center: .title(title),
      trailing: Array(trailing.prefix(2))  // 최대 2개
    )
  }

  /// Case 4: back + search TextField
  public static func backWithSearch(
    text: Binding<String>,
    placeholder: String,
    onBack: @escaping @MainActor () -> Void
  ) -> DoriNavigationBarConfig {
    DoriNavigationBarConfig(
      leading: .backButton(action: onBack),
      center: .searchField(text: text, placeholder: placeholder),
      trailing: []
    )
  }

  /// Case 5: title + trailing (back 없음)
  public static func titleWithActions(
    _ title: String,
    trailing: [TrailingItem] = []
  ) -> DoriNavigationBarConfig {
    DoriNavigationBarConfig(
      leading: .none,
      center: .title(title),
      trailing: Array(trailing.prefix(2))  // 최대 2개
    )
  }
}

// MARK: - DoriNavigationBar View

public struct DoriNavigationBar: View {
  private let config: DoriNavigationBarConfig

  public init(config: DoriNavigationBarConfig) {
    self.config = config
  }

  public var body: some View {
    HStack(spacing: 0) {
      // Leading
      leadingView

      Spacer(minLength: 0)

      // Trailing
      trailingView
    }
    .padding(.leading, 8)
    .padding(.trailing, 16)
    .frame(height: 44)
    .frame(maxWidth: .infinity)
    .overlay {
      // Center: 패딩 포함 전체 너비 기준 정중앙
      centerView
    }
    .background(.doriWhite)
  }

  // MARK: - Helpers

  private var searchFieldLeadingPadding: CGFloat {
    if case .none = config.leading { return 8 }
    return 52  // 8pt outer leading + 44pt back button
  }

  private var searchFieldTrailingPadding: CGFloat {
    16 + CGFloat(config.trailing.count) * 44  // 16pt outer trailing + 44pt per trailing item
  }

  // MARK: - Leading

  @ViewBuilder
  private var leadingView: some View {
    switch config.leading {
    case .none:
      EmptyView()

    case .backButton(let action):
      Button(action: action) {
        Image(systemName: "chevron.left")
          .foregroundStyle(.doriBlack)
          .frame(width: 44, height: 44)
          .contentShape(Rectangle())
      }
    }
  }

  // MARK: - Center

  @ViewBuilder
  private var centerView: some View {
    switch config.center {
    case .none:
      EmptyView()

    case .title(let title):
      Text(title)
        .pretendard(.headline(.h1))
        .foregroundStyle(.doriBlack)
        .frame(maxWidth: .infinity)

    case .searchField(let text, let placeholder, let onClear):
      HStack {
        TextField(placeholder, text: text)
          .pretendard(.body(.sb3))
          .foregroundStyle(.doriBlack)

        if !text.wrappedValue.isEmpty, let onClear {
          Button(action: onClear) {
            Image(systemName: "xmark.circle.fill")
              .foregroundStyle(.grey400)
          }
        }
      }
      .padding(.horizontal, 12)
      .frame(height: 36)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(.grey100)
      )
      .padding(.leading, searchFieldLeadingPadding)
      .padding(.trailing, searchFieldTrailingPadding)
    }
  }

  // MARK: - Trailing

  @ViewBuilder
  private var trailingView: some View {
    HStack(spacing: 0) {
      ForEach(config.trailing.indices, id: \.self) { index in
        let item = config.trailing[index]
        switch item {
        case .iconButton(let image, let action):
          Button(action: action) {
            image
              .foregroundStyle(.doriBlack)
              .frame(width: 44, height: 44)
              .contentShape(Rectangle())
          }
        }
      }
    }
  }

}

// MARK: - Swipe Back Gesture Helper

private struct NavigationControllerConfigurator: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> UIViewController {
    UIViewController()
  }

  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    DispatchQueue.main.async {
      if let navigationController = uiViewController.navigationController {
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        navigationController.interactivePopGestureRecognizer?.delegate = context.coordinator
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  class Coordinator: NSObject, UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
      // UILayoutContainerView에서 상위 responder chain을 탐색하여 UINavigationController 찾기
      var responder: UIResponder? = gestureRecognizer.view
      while let current = responder {
        if let navigationController = current as? UINavigationController {
          return navigationController.viewControllers.count > 1
        }
        responder = current.next
      }

      // 찾지 못한 경우 기본적으로 허용 (SwiftUI NavigationStack은 항상 허용)
      return true
    }

    // ScrollView와 동시에 인식되도록 허용
    func gestureRecognizer(
      _ gestureRecognizer: UIGestureRecognizer,
      shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
      return true
    }

    // Pop gesture가 다른 제스처(ScrollView 등)보다 우선하도록 설정
    func gestureRecognizer(
      _ gestureRecognizer: UIGestureRecognizer,
      shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
      // ScrollView의 pan gesture가 pop gesture에게 우선권 양보
      return otherGestureRecognizer is UIPanGestureRecognizer
    }
  }
}

// MARK: - ViewModifier

public struct DoriNavigationBarModifier: ViewModifier {
  let config: DoriNavigationBarConfig

  public init(config: DoriNavigationBarConfig) {
    self.config = config
  }

  public func body(content: Content) -> some View {
    content
      .navigationBarBackButtonHidden(true)
      .toolbar(.hidden, for: .navigationBar)
      .safeAreaInset(edge: .top, spacing: 0) {
        DoriNavigationBar(config: config)
      }
      .background(
        NavigationControllerConfigurator()
          .frame(width: 0, height: 0)
      )
  }
}

public extension View {
  func doriNavigationBar(_ config: DoriNavigationBarConfig) -> some View {
    modifier(DoriNavigationBarModifier(config: config))
  }
}

// MARK: - Preview

#Preview("Case 0: Empty") {
  NavigationStack {
    UIAsset.Colors.grey100.color
      .ignoresSafeArea()
      .doriNavigationBar(DoriNavigationBarConfig.empty)
  }
}

#Preview("Case 1: Back + Title") {
  NavigationStack {
    UIAsset.Colors.grey100.color
      .ignoresSafeArea()
      .doriNavigationBar(DoriNavigationBarConfig.backWithTitle("내역 추가", onBack: {}))
  }
}

#Preview("Case 2: Back + Title + 2 Actions") {
  NavigationStack {
    UIAsset.Colors.grey100.color
      .ignoresSafeArea()
      .doriNavigationBar(
        DoriNavigationBarConfig.backWithTitleAndActions(
          "김철수",
          onBack: {},
          trailing: [
            .iconButton(image: Image(systemName: "pencil"), action: {}),
            .iconButton(image: Image(systemName: "trash"), action: {})
          ]
        )
      )
  }
}

#Preview("Case 4: Back + Search") {
  @Previewable @State var searchText = ""

  NavigationStack {
    UIAsset.Colors.grey100.color
      .ignoresSafeArea()
      .doriNavigationBar(
        DoriNavigationBarConfig.backWithSearch(
          text: $searchText,
          placeholder: "이름 검색",
          onBack: {}
        )
      )
  }
}

#Preview("Case 5: Title Only") {
  NavigationStack {
    UIAsset.Colors.grey100.color
      .ignoresSafeArea()
      .doriNavigationBar(DoriNavigationBarConfig.titleWithActions("캘린더"))
  }
}
