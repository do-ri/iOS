//
//  AddDoriFeatureTests.swift
//  Dori-iOS
//
//  Created by 강동영 on 2/19/26.
//

import ComposableArchitecture
import DoriNetwork
import Testing
@testable import AddDori

// MARK: - Mock Data

private extension DoriResponsesDTO {
  static func mock(
    doriId: Int64 = 1,
    userId: Int64 = 1,
    partnerId: Int64 = 1,
    direction: String = "주도리",
    partnerName: String = "김철수",
    relationship: String = "친구",
    eventType: String = "결혼식",
    amount: Int32 = 100_000,
    eventDate: String = "2026-02-15",
    isVisited: Bool = true,
    memo: String = "",
    createdAt: String = "2026-02-15"
  ) -> DoriResponsesDTO {
    DoriResponsesDTO(
      doriId: doriId,
      userId: userId,
      partnerId: partnerId,
      direction: direction,
      partnerName: partnerName,
      relationship: relationship,
      eventType: eventType,
      amount: amount,
      eventDate: eventDate,
      isVisited: isVisited,
      memo: memo,
      createdAt: createdAt
    )
  }
}

// MARK: - Test Suite

@Suite("AddDoriFeature 테스트")
struct AddDoriFeatureTests {

  // MARK: - 초기 상태

  @Suite("초기 상태 확인")
  struct InitialStateTests {

    @Test("기본값 확인")
    func initialState() {
      let state = AddDoriFeature.State()
      #expect(state.currentPage == 0)
      #expect(state.transactionType == .judori)
      #expect(state.searchQuery == "")
      #expect(state.searchResults == [])
      #expect(state.selectedPartner == nil)
      #expect(state.isSearching == false)
      #expect(state.selectedRelationship == .friend)
      #expect(state.customRelationship == "")
      #expect(state.selectedEventType == .wedding)
      #expect(state.customEventType == "")
      #expect(state.amountText == "")
      #expect(state.isVisited == .yes)
      #expect(state.memo == "")
      #expect(state.isSubmitting == false)
    }
  }

  // MARK: - Validation

  @Suite("유효성 검사")
  struct ValidationTests {

    @Test("isPage1Valid - searchQuery만 있을 때 유효")
    func page1ValidWithSearchQuery() {
      var state = AddDoriFeature.State()
      state.searchQuery = "홍길동"
      #expect(state.isPage1Valid == true)
    }

    @Test("isPage1Valid - selectedPartner만 있을 때 유효")
    func page1ValidWithSelectedPartner() {
      var state = AddDoriFeature.State()
      state.selectedPartner = .mock()
      #expect(state.isPage1Valid == true)
    }

    @Test("isPage1Valid - 공백 searchQuery, partner 없으면 무효")
    func page1InvalidWhenEmpty() {
      var state = AddDoriFeature.State()
      state.searchQuery = "   "
      state.selectedPartner = nil
      #expect(state.isPage1Valid == false)
    }

    @Test("isPage2Valid - other 관계에 customRelationship 없으면 무효")
    func page2InvalidWithOtherRelationshipEmpty() {
      var state = AddDoriFeature.State()
      state.selectedRelationship = .other
      state.customRelationship = ""
      #expect(state.isPage2Valid == false)
    }

    @Test("isPage2Valid - other 관계에 customRelationship 있으면 유효")
    func page2ValidWithOtherRelationshipFilled() {
      var state = AddDoriFeature.State()
      state.selectedRelationship = .other
      state.customRelationship = "동창"
      state.selectedEventType = .wedding
      #expect(state.isPage2Valid == true)
    }

    @Test("isPage3Valid - 유효한 금액이면 true")
    func page3ValidWithAmount() {
      var state = AddDoriFeature.State()
      state.amountText = "50000"
      state.isVisited = .yes
      #expect(state.isPage3Valid == true)
    }

    @Test("isPage3Valid - 금액 0이면 무효")
    func page3InvalidWithZeroAmount() {
      var state = AddDoriFeature.State()
      state.amountText = "0"
      #expect(state.isPage3Valid == false)
    }

    @Test("isPage3Valid - 금액 비어있으면 무효")
    func page3InvalidWithEmptyAmount() {
      var state = AddDoriFeature.State()
      state.amountText = ""
      #expect(state.isPage3Valid == false)
    }

    @Test("isPage3Valid - 포맷된 문자열 '100,000'으로도 유효")
    func page3ValidWithFormattedAmount() {
      var state = AddDoriFeature.State()
      state.amountText = "100,000"
      state.isVisited = .yes
      #expect(state.isPage3Valid == true)
    }

    @Test("isPage3Valid - 공백 문자 포함된 포맷 문자열도 유효")
    func page3ValidWithLargeFormattedAmount() {
      var state = AddDoriFeature.State()
      state.amountText = "1,000,000"
      state.isVisited = .yes
      #expect(state.isPage3Valid == true)
    }
  }

  // MARK: - Navigation

  @Suite("페이지 네비게이션")
  struct NavigationTests {

    @Test("nextPageTapped - 0에서 1로 이동")
    func nextPageFrom0To1() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      await store.send(.nextPageTapped) {
        $0.currentPage = 1
      }
    }

    @Test("nextPageTapped - 1에서 2로 이동")
    func nextPageFrom1To2() async {
      var initial = AddDoriFeature.State()
      initial.currentPage = 1

      let store = TestStore(
        initialState: initial
      ) {
        AddDoriFeature()
      }

      await store.send(.nextPageTapped) {
        $0.currentPage = 2
      }
    }

    @Test("nextPageTapped - 2에서 no-op")
    func nextPageFrom2IsNoOp() async {
      var initial = AddDoriFeature.State()
      initial.currentPage = 2

      let store = TestStore(
        initialState: initial
      ) {
        AddDoriFeature()
      }

      await store.send(.nextPageTapped)
    }

    @Test("previousPageTapped - 2에서 1로 이동")
    func previousPageFrom2To1() async {
      var initial = AddDoriFeature.State()
      initial.currentPage = 2

      let store = TestStore(
        initialState: initial
      ) {
        AddDoriFeature()
      }

      await store.send(.previousPageTapped) {
        $0.currentPage = 1
      }
    }

    @Test("previousPageTapped - 1에서 0으로 이동")
    func previousPageFrom1To0() async {
      var initial = AddDoriFeature.State()
      initial.currentPage = 1

      let store = TestStore(
        initialState: initial
      ) {
        AddDoriFeature()
      }

      await store.send(.previousPageTapped) {
        $0.currentPage = 0
      }
    }

    @Test("previousPageTapped - 0에서 no-op")
    func previousPageFrom0IsNoOp() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      await store.send(.previousPageTapped)
    }
  }

  // MARK: - Page 1: 이름/구분

  @Suite("Page 1 - 이름/구분")
  struct Page1Tests {

    @Test("transactionTypeChanged - 받도리로 변경")
    func transactionTypeChanged() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      await store.send(.transactionTypeChanged(.baddori)) {
        $0.transactionType = .baddori
      }
    }

    @Test("searchQueryChanged - 검색어 입력 시 isSearching = true + Effect 실행")
    func searchQueryChangedTriggersEffect() async {
      let mockResults = [DoriResponsesDTO.mock(partnerName: "김철수")]

      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      } withDependencies: {
        $0.continuousClock = ImmediateClock()
        $0.addDoriAPIClient.searchPartners = { _ in mockResults }
      }

      await store.send(.searchQueryChanged("김철수")) {
        $0.searchQuery = "김철수"
        $0.selectedPartner = nil
        $0.isSearching = true
      }

      await store.receive(.searchResponse(mockResults)) {
        $0.searchResults = mockResults
        $0.isSearching = false
      }
    }

    @Test("searchQueryChanged - 10자 초과 시 앞 10자만 저장")
    func searchQueryChangedTruncatedAt10() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      } withDependencies: {
        $0.continuousClock = ImmediateClock()
        $0.addDoriAPIClient.searchPartners = { _ in [] }
      }

      let longQuery = "12345678901234"
      await store.send(.searchQueryChanged(longQuery)) {
        $0.searchQuery = "1234567890"
        $0.selectedPartner = nil
        $0.isSearching = true
      }

      await store.receive(.searchResponse([])) {
        $0.searchResults = []
        $0.isSearching = false
      }
    }

    @Test("searchQueryChanged - 빈 문자열 입력 시 results 초기화, isSearching = false")
    func searchQueryChangedWithEmptyStringClearsResults() async {
      var initial = AddDoriFeature.State()
      initial.searchQuery = "김"
      initial.searchResults = [.mock()]
      initial.isSearching = true

      let store = TestStore(
        initialState: initial
      ) {
        AddDoriFeature()
      }

      await store.send(.searchQueryChanged("")) {
        $0.searchQuery = ""
        $0.selectedPartner = nil
        $0.searchResults = []
        $0.isSearching = false
      }
    }

    @Test("searchQueryChanged - 공백만 입력 시 results 초기화")
    func searchQueryChangedWithWhitespaceOnlyClearsResults() async {
      var initial = AddDoriFeature.State()
      initial.searchResults = [.mock()]

      let store = TestStore(
        initialState: initial
      ) {
        AddDoriFeature()
      }

      await store.send(.searchQueryChanged("   ")) {
        $0.searchQuery = "   "
        $0.selectedPartner = nil
        $0.searchResults = []
        $0.isSearching = false
      }
    }

    @Test("searchResponse - results 업데이트 및 isSearching = false")
    func searchResponseUpdatesResults() async {
      var initial = AddDoriFeature.State()
      initial.isSearching = true

      let store = TestStore(
        initialState: initial
      ) {
        AddDoriFeature()
      }

      let results = [DoriResponsesDTO.mock()]
      await store.send(.searchResponse(results)) {
        $0.searchResults = results
        $0.isSearching = false
      }
    }

    @Test("partnerSelected - 파트너 선택 시 searchQuery, relationship 업데이트")
    func partnerSelectedUpdatesState() async {
      var initial = AddDoriFeature.State()
      initial.searchResults = [.mock(partnerName: "박민수", relationship: "회사")]

      let store = TestStore(
        initialState: initial
      ) {
        AddDoriFeature()
      }

      let partner = DoriResponsesDTO.mock(
        partnerName: "박민수",
        relationship: "회사"
      )

      await store.send(.partnerSelected(partner)) {
        $0.selectedPartner = partner
        $0.searchQuery = "박민수"
        $0.searchResults = []
        $0.selectedRelationship = .company
      }
    }

    @Test("partnerSelected - unknown relationship 파트너 선택 시 customRelationship 설정")
    func partnerSelectedWithUnknownRelationship() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      let partner = DoriResponsesDTO.mock(
        partnerName: "홍길동",
        relationship: "지인"
      )

      await store.send(.partnerSelected(partner)) {
        $0.selectedPartner = partner
        $0.searchQuery = "홍길동"
        $0.searchResults = []
        $0.selectedRelationship = .other
        $0.customRelationship = "지인"
      }
    }

    @Test("partnerSelected(nil) - 선택 해제")
    func partnerDeselected() async {
      var initial = AddDoriFeature.State()
      initial.selectedPartner = .mock()

      let store = TestStore(
        initialState: initial
      ) {
        AddDoriFeature()
      }

      await store.send(.partnerSelected(nil)) {
        $0.selectedPartner = nil
      }
    }

    @Test("clearSearchTapped - 검색 상태 전체 초기화")
    func clearSearchTappedResetsSearchState() async {
      // clearSearchTapped Reducer는 isSearching을 별도로 변경하지 않으므로
      // initial에서 isSearching은 기본값(false)으로 유지한다
      var initial = AddDoriFeature.State()
      initial.searchQuery = "김철수"
      initial.searchResults = [.mock()]
      initial.selectedPartner = .mock()

      let store = TestStore(
        initialState: initial
      ) {
        AddDoriFeature()
      }

      await store.send(.clearSearchTapped) {
        $0.searchQuery = ""
        $0.searchResults = []
        $0.selectedPartner = nil
      }
    }
  }

  // MARK: - Page 2: 관계/경조사

  @Suite("Page 2 - 관계/경조사")
  struct Page2Tests {

    @Test("relationshipSelected - 관계 변경")
    func relationshipSelected() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      await store.send(.relationshipSelected(.family)) {
        $0.selectedRelationship = .family
      }
    }

    @Test("relationshipSelected - other 아닌 값 선택 시 customRelationship 초기화")
    func relationshipSelectedClearsCustomWhenNotOther() async {
      var initial = AddDoriFeature.State()
      initial.selectedRelationship = .other
      initial.customRelationship = "동창"

      let store = TestStore(
        initialState: initial
      ) {
        AddDoriFeature()
      }

      await store.send(.relationshipSelected(.friend)) {
        $0.selectedRelationship = .friend
        $0.customRelationship = ""
      }
    }

    @Test("customRelationshipChanged - 10자 이내 저장")
    func customRelationshipChangedWithinLimit() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      await store.send(.customRelationshipChanged("동창친구")) {
        $0.customRelationship = "동창친구"
      }
    }

    @Test("customRelationshipChanged - 10자 초과 시 앞 10자만 저장")
    func customRelationshipChangedTruncatedAt10() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      let longText = "12345678901234"
      await store.send(.customRelationshipChanged(longText)) {
        $0.customRelationship = "1234567890"
      }
    }

    @Test("eventTypeSelected - 경조사 변경")
    func eventTypeSelected() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      await store.send(.eventTypeSelected(.funeral)) {
        $0.selectedEventType = .funeral
      }
    }

    @Test("eventTypeSelected - other 아닌 값 선택 시 customEventType 초기화")
    func eventTypeSelectedClearsCustomWhenNotOther() async {
      var initial = AddDoriFeature.State()
      initial.selectedEventType = .other
      initial.customEventType = "회갑잔치"

      let store = TestStore(
        initialState: initial
      ) {
        AddDoriFeature()
      }

      await store.send(.eventTypeSelected(.birthday)) {
        $0.selectedEventType = .birthday
        $0.customEventType = ""
      }
    }

    @Test("customEventTypeChanged - 10자 초과 시 앞 10자만 저장")
    func customEventTypeChangedTruncatedAt10() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      let longText = "가나다라마바사아자차카"
      await store.send(.customEventTypeChanged(longText)) {
        $0.customEventType = "가나다라마바사아자차"
      }
    }
  }

  // MARK: - Page 3: 금액/날짜

  @Suite("Page 3 - 금액/날짜")
  struct Page3Tests {

    @Test("amountTextChanged - 빈 문자열 입력 시 빈 문자열 저장")
    func amountTextChangedWithEmptyString() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      await store.send(.amountTextChanged("")) {
        $0.amountText = ""
      }
    }

    @Test("amountTextChanged - 문자 포함 입력 시 숫자만 추출 후 포맷")
    func amountTextChangedFiltersNumbers() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      await store.send(.amountTextChanged("10a0b0c")) {
        $0.amountText = "1,000"
      }
    }

    @Test("amountTextChanged - 100,000 포맷팅 검증")
    func amountTextChangedFormatsDecimal() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      await store.send(.amountTextChanged("100000")) {
        $0.amountText = "100,000"
      }
    }

    @Test("amountTextChanged - 순수 숫자 입력")
    func amountTextChangedWithPureNumbers() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      await store.send(.amountTextChanged("50000")) {
        $0.amountText = "50,000"
      }
    }

    @Test("amountTextChanged - 21억 초과 입력 시 Int32.max로 클리핑")
    func amountTextChangedClipsAtInt32Max() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      await store.send(.amountTextChanged("9999999999")) {
        $0.amountText = Int(Int32.max).decimalFormatted
      }
    }

    @Test("amountTextChanged - Int32.max 정확히 입력 시 그대로 저장")
    func amountTextChangedWithExactInt32Max() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      await store.send(.amountTextChanged("\(Int32.max)")) {
        $0.amountText = Int(Int32.max).decimalFormatted
      }
    }

    @Test("addAmountTapped - 기존 금액에 추가")
    func addAmountTappedAddsToExisting() async {
      var initial = AddDoriFeature.State()
      initial.amountText = "30,000"

      let store = TestStore(
        initialState: initial
      ) {
        AddDoriFeature()
      }

      await store.send(.addAmountTapped(10_000)) {
        $0.amountText = "40,000"
      }
    }

    @Test("addAmountTapped - 빈 금액에서 추가")
    func addAmountTappedFromEmpty() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      await store.send(.addAmountTapped(50_000)) {
        $0.amountText = "50,000"
      }
    }

    @Test("addAmountTapped - 21억 초과 시 Int32.max로 클리핑")
    func addAmountTappedClipsAtInt32Max() async {
      var initial = AddDoriFeature.State()
      initial.amountText = Int(Int32.max - 100).decimalFormatted

      let store = TestStore(
        initialState: initial
      ) {
        AddDoriFeature()
      }

      await store.send(.addAmountTapped(1_000_000)) {
        $0.amountText = Int(Int32.max).decimalFormatted
      }
    }

    @Test("eventDateChanged - 날짜 변경")
    func eventDateChanged() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      let newDate = Date(timeIntervalSince1970: 1_739_923_200) // 2025-02-19
      await store.send(.eventDateChanged(newDate)) {
        $0.eventDate = newDate
      }
    }

    @Test("isVisitedChanged - 방문 여부 변경")
    func isVisitedChanged() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      await store.send(.isVisitedChanged(.no)) {
        $0.isVisited = .no
      }
    }

    @Test("memoChanged - 40자 이내 저장")
    func memoChangedWithinLimit() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      await store.send(.memoChanged("좋은 자리였습니다")) {
        $0.memo = "좋은 자리였습니다"
      }
    }

    @Test("memoChanged - 40자 초과 시 앞 40자만 저장")
    func memoChangedTruncatedAt40() async {
      let store = TestStore(
        initialState: AddDoriFeature.State()
      ) {
        AddDoriFeature()
      }

      let longMemo = String(repeating: "가", count: 50)
      let expected = String(repeating: "가", count: 40)
      await store.send(.memoChanged(longMemo)) {
        $0.memo = expected
      }
    }
  }

  // MARK: - Submit

  @Suite("Submit - 등록/수정")
  struct SubmitTests {

    @Test("create 모드 - 제출 성공 시 doriCreated delegate 발생")
    func createSubmitSuccess() async {
      var initial = AddDoriFeature.State()
      initial.searchQuery = "김철수"
      initial.selectedRelationship = .friend
      initial.selectedEventType = .wedding
      initial.amountText = "100,000"
      initial.isVisited = .yes

      let mockResponse = DoriResponsesDTO.mock(
        partnerName: "김철수",
        relationship: "친구",
        eventType: "결혼식",
        amount: 100_000
      )

      let store = TestStore(
        initialState: initial
      ) {
        AddDoriFeature()
      } withDependencies: {
        $0.addDoriAPIClient.createDori = { _ in mockResponse }
      }

      await store.send(.submitTapped) {
        $0.isSubmitting = true
      }

      await store.receive(.submitResponse(.success(mockResponse))) {
        $0.isSubmitting = false
      }

      await store.receive(.delegate(.doriCreated(mockResponse)))
    }

    @Test("create 모드 - 제출 실패 시 isSubmitting = false")
    func createSubmitFailure() async {
      var initial = AddDoriFeature.State()
      initial.searchQuery = "김철수"
      initial.amountText = "100,000"

      struct TestError: Error {
        let message = "서버 오류"
        var localizedDescription: String { message }
      }

      let store = TestStore(
        initialState: initial
      ) {
        AddDoriFeature()
      } withDependencies: {
        $0.addDoriAPIClient.createDori = { _ in throw TestError() }
      }

      await store.send(.submitTapped) {
        $0.isSubmitting = true
      }

      await store.receive(
        .submitResponse(
          .failure(
            AddDoriFeature.SubmitError(message: "서버 오류")
          )
        )
      ) {
        $0.isSubmitting = false
      }
    }

    @Test("create 모드 - request에 올바른 값이 전달되는지 검증")
    func createSubmitRequestValues() async {
      var initial = AddDoriFeature.State()
      initial.transactionType = .judori
      initial.searchQuery = "박수진"
      initial.selectedRelationship = .friend
      initial.selectedEventType = .wedding
      initial.amountText = "100,000"
      initial.isVisited = .yes
      initial.memo = "테스트 메모"

      let mockResponse = DoriResponsesDTO.mock(partnerName: "박수진")

      nonisolated(unsafe) var capturedRequest: DoriPostRequest?

      let store = TestStore(
        initialState: initial
      ) {
        AddDoriFeature()
      } withDependencies: {
        $0.addDoriAPIClient.createDori = { request in
          capturedRequest = request
          return mockResponse
        }
      }

      await store.send(.submitTapped) {
        $0.isSubmitting = true
      }

      await store.receive(.submitResponse(.success(mockResponse))) {
        $0.isSubmitting = false
      }

      await store.receive(.delegate(.doriCreated(mockResponse)))

      #expect(capturedRequest?.direction == "주도리")
      #expect(capturedRequest?.partnerName == "박수진")
      #expect(capturedRequest?.relationship == "친구")
      #expect(capturedRequest?.eventType == "결혼식")
      #expect(capturedRequest?.amount == 100_000)
      #expect(capturedRequest?.isVisited == true)
      #expect(capturedRequest?.memo == "테스트 메모")
    }

    @Test("isSubmitting = true 상태에서 submitTapped - no-op")
    func submitTappedWhileSubmittingIsNoOp() async {
      var initial = AddDoriFeature.State()
      initial.isSubmitting = true

      let store = TestStore(
        initialState: initial
      ) {
        AddDoriFeature()
      }

      await store.send(.submitTapped)
    }
  }

  // MARK: - Computed Properties

  @Suite("Computed Properties")
  struct ComputedPropertyTests {

    @Test("partnerName - selectedPartner가 있으면 partnerName 반환")
    func partnerNameFromSelectedPartner() {
      var state = AddDoriFeature.State()
      state.selectedPartner = .mock(partnerName: "박철수")
      state.searchQuery = "박"
      #expect(state.partnerName == "박철수")
    }

    @Test("partnerName - selectedPartner 없으면 searchQuery trim 반환")
    func partnerNameFromSearchQuery() {
      var state = AddDoriFeature.State()
      state.selectedPartner = nil
      state.searchQuery = "  홍길동  "
      #expect(state.partnerName == "홍길동")
    }

    @Test("resolvedRelationship - other 선택 시 customRelationship 반환")
    func resolvedRelationshipWithOther() {
      var state = AddDoriFeature.State()
      state.selectedRelationship = .other
      state.customRelationship = "지인"
      #expect(state.resolvedRelationship == "지인")
    }

    @Test("resolvedRelationship - known 선택 시 rawValue 반환")
    func resolvedRelationshipWithKnown() {
      var state = AddDoriFeature.State()
      state.selectedRelationship = .friend
      #expect(state.resolvedRelationship == "친구")
    }

    @Test("resolvedEventType - other 선택 시 customEventType 반환")
    func resolvedEventTypeWithOther() {
      var state = AddDoriFeature.State()
      state.selectedEventType = .other
      state.customEventType = "회갑잔치"
      #expect(state.resolvedEventType == "회갑잔치")
    }

    @Test("resolvedEventType - known 선택 시 rawValue 반환")
    func resolvedEventTypeWithKnown() {
      var state = AddDoriFeature.State()
      state.selectedEventType = .wedding
      #expect(state.resolvedEventType == "결혼식")
    }
  }
}
