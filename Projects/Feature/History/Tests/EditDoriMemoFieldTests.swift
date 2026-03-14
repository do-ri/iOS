import Combine
import ComposableArchitecture
import DoriCore
import SwiftUI
import Testing
import UIKit
@testable import FeatureHistory

@MainActor
@Suite("EditDori 메모 입력")
struct EditDoriMemoFieldTests {

  @Test("memoChanged 액션은 40자로 제한된다")
  func memoChangedCapsAt40Characters() async {
    let store = TestStore(
      initialState: EditDoriFeature.State(dori: .fixture())
    ) {
      EditDoriFeature()
    }

    let longText = String(repeating: "a", count: 45)

    await store.send(.memoChanged(longText)) {
      $0.memo = String(longText.prefix(40))
    }
  }

  @MainActor
  @Test("긴 한 줄 메모는 너비를 넘기면 자동 줄바꿈되며 높이가 증가한다")
  func memoFieldWrapsAndExpandsHeight() async throws {
    let host = try makeHost()
    let initialHeight = host.textView.frame.height

    host.state.text = String(repeating: "가", count: 40)
    await settleLayout(controller: host.controller)

    #expect(host.textView.frame.height > initialHeight)
  }

  @MainActor
  @Test("41자 이상 입력하면 컴포넌트에서도 40자로 즉시 잘린다")
  func memoFieldTruncatesPast40Characters() async throws {
    let host = try makeHost()

    host.textView.text = String(repeating: "b", count: 45)
    host.textView.delegate?.textViewDidChange?(host.textView)
    await settleLayout(controller: host.controller)

    #expect(host.state.text.count == 40)
    #expect(host.textView.text.count == 40)
  }
}

@MainActor
private func makeHost() throws -> (
  window: UIWindow,
  controller: UIHostingController<MemoFieldHarness>,
  state: MemoFieldState,
  textView: UITextView
) {
  let state = MemoFieldState()
  let controller = UIHostingController(
    rootView: MemoFieldHarness(state: state)
  )
  let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 400))
  window.rootViewController = controller
  window.makeKeyAndVisible()

  controller.view.frame = window.bounds
  controller.view.layoutIfNeeded()

  guard let textView = controller.view.firstSubview(of: UITextView.self) else {
    throw MemoFieldHostError.textViewNotFound
  }

  return (window, controller, state, textView)
}

@MainActor
private func settleLayout(controller: UIViewController) async {
  controller.view.setNeedsLayout()
  controller.view.layoutIfNeeded()
  try? await Task.sleep(for: .milliseconds(50))
  controller.view.setNeedsLayout()
  controller.view.layoutIfNeeded()
}

@MainActor
private final class MemoFieldState: ObservableObject {
  @Published var text = ""
}

private struct MemoFieldHarness: View {
  @ObservedObject var state: MemoFieldState

  var body: some View {
    EditDoriMemoField(
      "메모를 입력해주세요 (40자)",
      text: Binding(
        get: { state.text },
        set: { state.text = $0 }
      ),
      maxLength: 40
    )
    .frame(width: 180)
  }
}

private enum MemoFieldHostError: Error {
  case textViewNotFound
}

private extension UIView {
  func firstSubview<T: UIView>(of type: T.Type) -> T? {
    if let view = self as? T {
      return view
    }

    for subview in subviews {
      if let view = subview.firstSubview(of: type) {
        return view
      }
    }

    return nil
  }
}

private extension Dori {
  static func fixture(memo: String = "") -> Dori {
    Dori(
      doriId: 1,
      userId: 1,
      partnerId: 1,
      direction: .judori,
      partnerName: "홍길동",
      relationship: "친구",
      eventType: "결혼식",
      amount: 50_000,
      eventDate: "2026-03-14",
      isVisited: true,
      memo: memo,
      createdAt: "2026-03-14"
    )
  }
}
