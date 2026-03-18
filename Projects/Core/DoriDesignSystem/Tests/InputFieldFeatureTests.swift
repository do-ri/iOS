import ComposableArchitecture
import Testing
@testable import DoriDesignSystem

@Suite("InputFieldFeature")
struct InputFieldFeatureTests {

  @Test("21억 초과 입력 시 21억으로 캡핑하고 입력 한도 에러를 노출한다")
  @MainActor
  func amountTextChangedCapsAtLimit() async {
    let store = TestStore(
      initialState: InputFieldFeature.State(
        variant: .amount(maxAmount: 2_100_000_000),
        trailing: .unitAndClear(unitText: "원"),
        placeholder: "금액을 입력해주세요"
      )
    ) {
      InputFieldFeature()
    }

    await store.send(.textChanged("9999999999")) {
      $0.text = "2100000000"
      $0.state = .error(message: "*입력 한도")
    }

    await store.receive(.triggerErrorHaptic)
  }

  @Test("상한값과 동일한 입력은 정상값으로 유지한다")
  @MainActor
  func amountTextChangedAllowsExactLimit() async {
    let store = TestStore(
      initialState: InputFieldFeature.State(
        variant: .amount(maxAmount: 2_100_000_000)
      )
    ) {
      InputFieldFeature()
    }

    await store.send(.textChanged("2100000000")) {
      $0.text = "2100000000"
    }
  }

  @Test("clear 버튼 탭 시 텍스트와 에러 상태를 함께 초기화한다")
  @MainActor
  func clearButtonTappedResetsTextAndError() async {
    let store = TestStore(
      initialState: InputFieldFeature.State(
        text: "2100000000",
        variant: .amount(maxAmount: 2_100_000_000),
        state: .error(message: "*입력 한도"),
        trailing: .unitAndClear(unitText: "원")
      )
    ) {
      InputFieldFeature()
    }

    await store.send(.clearButtonTapped) {
      $0.text = ""
      $0.state = .normal
    }
  }
}
