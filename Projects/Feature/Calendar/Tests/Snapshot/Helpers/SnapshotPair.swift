import SnapshotTesting
import SwiftUI
import XCTest

/// Assert a SwiftUI view's snapshot in both light and dark interface styles.
///
/// 한 호출로 light/dark 페어 baseline 을 생성한다. swift-snapshot-testing 의 `named:` 인자가
/// 동일 `testName` 안에서 light/dark PNG 를 다른 이름으로 보존하므로 파일명 충돌이 없다.
///
/// 다크모드를 그리는 View 스냅샷은 본 헬퍼를 통과시켜 페어 누락을 구조적으로 방지한다.
@MainActor
func assertSnapshotPair<V: View>(
  of view: @autoclosure () -> V,
  layout: SwiftUISnapshotLayout = .sizeThatFits,
  record: Bool? = nil,
  fileID: StaticString = #fileID,
  file: StaticString = #filePath,
  testName: String = #function,
  line: UInt = #line,
  column: UInt = #column
) {
  let rendered = view()
  assertSnapshot(
    of: rendered,
    as: .image(
      layout: layout,
      traits: UITraitCollection(userInterfaceStyle: .light)
    ),
    named: "light",
    record: record,
    fileID: fileID,
    file: file,
    testName: testName,
    line: line,
    column: column
  )
  assertSnapshot(
    of: rendered,
    as: .image(
      layout: layout,
      traits: UITraitCollection(userInterfaceStyle: .dark)
    ),
    named: "dark",
    record: record,
    fileID: fileID,
    file: file,
    testName: testName,
    line: line,
    column: column
  )
}
