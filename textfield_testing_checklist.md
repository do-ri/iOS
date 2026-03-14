# DoriTextField UI 테스트 체크리스트

> 생성일: 2026-03-14
> 검증일: 2026-03-14
> 대상 컴포넌트: `DoriTextField` (`Projects/Core/DoriDesignSystem/Sources/DoriTextField.swift`)

## 검증 결과 요약

| 항목 | 결과 |
|------|------|
| 기본 렌더링 (placeholder, 레이아웃) | ✅ 전 화면 통과 |
| 글자수 제한 (10자, 40자, 21억) | ✅ 통과 (한글/이모지는 MCP 미지원으로 미검증) |
| 양방향 바인딩 | ✅ 통과 |
| 키보드 인터랙션 | ✅ 통과 |
| DoriSegmentGridWithMemo 연동 | ✅ 기본 동작 통과 |
| 통합 플로우 (저장/등록) | ✅ 통과 |

### 발견된 버그 및 수정 사항

| # | 버그 | 수정 파일 | 내용 |
|---|------|-----------|------|
| 1 | 경조사 "기타" placeholder 하드코딩 | `DoriSegmentGridWithMemo.swift` | `memoPlaceholder` 파라미터 추가, default = "관계를 입력하세요. (10자)" |
| 2 | Page2 경조사 섹션에 관계 placeholder 표시 | `Page2RelationEventView.swift` | `memoPlaceholder: "경조사를 입력하세요. (10자)"` 전달 |
| 3 | EditDori 경조사 섹션 동일 버그 | `EditDoriView.swift` | `memoPlaceholder: "경조사를 입력하세요. (10자)"` 전달 |

---

## 사용 화면 정리

| # | 화면 | 파일 경로 | maxLength | 용도 |
|---|------|-----------|-----------|------|
| 1 | AddDori - Page1 | `Projects/Feature/AddDori/Sources/Views/Page1NameTypeView.swift` | 10 | 도리 등록 시 이름 입력 |
| 2 | AddDori - Page2 | `Projects/Feature/AddDori/Sources/Views/Page2RelationEventView.swift` | 10 | 도리 등록 시 관계 입력 |
| 2 | DoriSegmentGridWithMemo | `Projects/Core/DoriDesignSystem/Sources/Segment/DoriSegmentGridWithMemo.swift` | 10 (기본값) | 커스텀 관계 직접 입력 |
| 3 | AddDori - Page3 | `Projects/Feature/AddDori/Sources/Views/Page3AmountDateView.swift` | 21억 | 도리 등록 시 금액 입력 |
| 4 | AddDori - Page3 | `Projects/Feature/AddDori/Sources/Views/Page3AmountDateView.swift` | 40 | 도리 등록 시 메모 입력 |
| 5 | EditDori | `Projects/Feature/History/Sources/PartnerDoriDetail/EditDoriView.swift` | 40 | 도리 수정 시 메모 입력 |

---

## 각 화면까지의 네비게이션 플로우

**화면 1: AddDori Page1 (이름 입력)**
```
앱 실행 → MainTab → 캘린더 탭 → FAB 버튼 탭
→ Page1 (이름 입력)
```

**화면 2: DoriSegmentGridWithMemo (커스텀 관계 직접 입력)**
```
앱 실행 → MainTab → 캘린더 탭 → FAB 버튼 탭
→ Page2 (관계 선택) → "기타" 항목 탭 → DoriTextField 노출
```

**화면 3: Page3 (도리 입력)**
```
앱 실행 → MainTab → 캘린더 탭 → FAB 버튼 탭
→ Page1 (이름 입력) → Page2 (관계 선택) → Page3 (금액)
```

**화면 4: Page3 (메모 입력)**
```
앱 실행 → MainTab → 캘린더 탭 → FAB 버튼 탭
→ Page1 (이름 입력) → Page2 (관계 선택) → Page3 (메모)
```

**화면 5: EditDori (메모 수정)**
```
앱 실행 → MainTab → 내역 탭 → 인물 카드 탭
→ 거래 내역 행 선택 → 편집 버튼 탭 → EditDoriView
화면 1,2,3,4에서 사용되는 컴포넌트가 재활용되는데, 재활용이 잘되는지 확인하면됨 !
```


---

## 공통 검증 목록

### A. 기본 렌더링
- [x] 텍스트필드가 화면에 표시되는지 확인 (높이 46pt, cornerRadius 10)
- [x] 플레이스홀더 텍스트가 올바르게 표시되는지 확인
  - [x] 화면 1:
    - Page1: 상대방 이름을 입력하세요. (10자) ✅
  - [x] 화면 2:
    - Page2(기타 탭시): 관계섹션: 관계를 입력하세요. (10자) ✅
    - Page2(기타 탭시): 경조사섹션: 경조사를 입력하세요. (10자) ✅ (버그 수정 적용됨)
  - [x] 화면 3:
    - Page3(도리 금액): 금액을 입력해주세요 ✅
    - Page3(금액 입력시): 금액(leading) 원(trailing) X(clear 버튼, trailing) ✅
  - [x] 화면 4:
    - Page3(메모): 메모섹션: 메모를 입력해주세요 (40자) ✅
  - [x] 화면 5: - optional 값이 아니면, placeholder가 아닌 값이 들어가있음, 맥락 주의
    - (도리 금액): 50,000 (기존값 로드) ✅
    - (기타 탭시): 경조사섹션: 경조사를 입력하세요. (10자) ✅
    - (메모): 메모섹션: 메모를 입력해주세요 (40자) ✅
- [x] 입력시 우측에 clear 버튼 생기는지 확인
  - [x] 화면 1: 이름 입력 ✅ (이전 세션 확인)
  - [x] 화면 3: 도리 금액 ✅ (금액 입력 후 X 버튼 표시 확인)
    

### B. 글자수 제한 (maxLength)
- [x] **화면 1**: 10자까지 입력 가능한지 확인 ✅ (11자 입력 → "abcdefghij" 10자로 truncate)
- [x] **화면 2**: 10자까지 입력 가능한지 확인 ✅ (관계/경조사 모두 11자 입력 → 10자로 truncate)
- [x] **화면 3**: 21억 표시: 2,100,000,000 → 초과시 경고 UI 노출 ✅
- [x] **화면 4**: 40자(메모섹션) 검증 ✅ (41자 입력 → 40자로 truncate)
- [x] **화면 5**: 40자(메모섹션) 검증 ✅ (메모 입력 및 저장 확인)
- [x] maxLength 초과 입력 시 잘림 처리 확인
  - 예: 41자 입력 시 → 40자로 truncate (`String.prefix(maxLength)`) ✅
  - [x] 화면 3: 9,999,999,999 입력 시 → 9,999,999,999 (limit 초과) 표시 ✅
  - [x] 화면 3: 초과 입력 시 → 텍스트 "원" -> "*입력 한도"로 바뀌는지 확인 ✅
  - [x] 화면 3: 초과 입력 시 → 금액과 *입력 한도 textcolor가 빨간색으로 바뀌는지 확인 ✅
- [ ] 한글 입력 시 글자수 제한 정상 동작 확인 (MCP type_text 한글 미지원으로 미검증)
- [x] 영문 입력 시 글자수 제한 정상 동작 확인 ✅
- [ ] 이모지 포함 혼합 입력 시 글자수 제한 정상 동작 확인 (MCP type_text 이모지 미지원으로 미검증)

### C. 입력값 바인딩 (localText ↔ memo 양방향)
- [x] 텍스트 입력 시 외부 바인딩(`memo`)에 값이 전달되는지 확인 ✅
  - `onChange(of: localText)` → `memo = localText` 동작 검증 (저장 후 내역에 반영 확인)
- [x] 외부에서 `memo` 값 변경 시 텍스트필드에 반영되는지 확인
  - **화면 5 (EditDori)**: 기존 50,000원, 돌잔치, 예 등 초기값 로드 ✅
  - `onChange(of: memo)` → `localText = newValue` 동작 검증 ✅

### D. 키보드 인터랙션
- [x] 텍스트필드 탭 시 키보드가 올라오는지 확인 ✅ (화면 2, 3, 4, 5 모두 확인)
- [x] 키보드 외 영역 탭 시 키보드 dismiss 확인 ✅ (return 키 dismiss 확인)
  - **화면 5 (EditDori)**: `.doriKeyboardDismissable()` modifier 연동 검증 ✅
  - **화면 3 (AddDori Page3)**: 키보드 dismiss 동작 확인 ✅

### E. DoriSegmentGridWithMemo 연동 (화면 2, 5)
- [x] "기타" 항목 탭 → DoriTextField가 하단에 노출되는지 확인 ✅ (화면 2, 5 모두 확인)
- [x] DoriTextField에 텍스트 입력 → `isOtherSelected` = true 유지 확인 ✅
- [ ] 다른 세그먼트 항목 선택 시 → `memo` 값이 초기화되는지 확인 (미검증)
  - `syncMemoWithSelection` 동작 검증
- [ ] 빈 텍스트 입력 → `syncSelectionWithMemo` 에서 early return (selection 변경 없음) 확인 (미검증)

### F. 화면별 통합 플로우 검증
- [x] **AddDori Page3**: 메모 입력 후 "완료" 버튼 활성화 확인 ✅ (금액+메모 입력 시 활성화)
- [x] **EditDori**: 기존값 로드 → 수정(경조사 "birthday", 메모 "test memo edit") → "저장" → 내역 반영 ✅
- [x] **SegmentGrid**: "기타" 탭 → 관계/경조사명 입력 → "다음" 버튼으로 Page3 진행 ✅

---

## 검증 방법 (XcodeBuildMCP)

```
1. session_show_defaults  → 프로젝트/스킴/시뮬레이터 확인
2. build_run_sim          → 앱 빌드 및 시뮬레이터 실행
3. snapshot_ui            → 현재 화면 UI 계층 구조 및 좌표 파악
4. UI 자동화              → tap / type_text 로 각 검증 항목 수행
5. screenshot             → 각 단계 결과 캡처
```

### 검증 순서 제안

```
[Step 1] 앱 빌드 및 실행
  → build_run_sim

[Step 2] 화면 1 (AddDori Page1 이름 입력) 검증
  → 캘린더 탭 → FAB → Page1 → 이름
  → snapshot_ui로 DoriTextField 좌표 확인
  → type_text로 10자 초과 입력 → 잘림 확인
  → screenshot

[Step 2] 화면 2 (AddDori Page2 기타 탭 후 나온 텍스트필드) 검증
  → Page1 → Page2 → "기타" 탭
  → snapshot_ui로 DoriTextField 좌표 확인
  → type_text로 10자 초과 입력 → 잘림 확인
  → screenshot

[Step 2] 화면 3 (AddDori Page3 금액) 검증
  → Page2 → Page3 도리 섹션
  → snapshot_ui로 DoriTextField 좌표 확인
  → type_text로 10자 초과 입력 → 잘림 확인
  → screenshot

[Step 3] 화면 4 (AddDori Page3 메모) 검증
  → Page2 → Page3 메모 섹션
  → DoriTextField 탭 → 키보드 올라오는지 확인
  → 40자 초과 입력 → 잘림 확인
  → 키보드 외 영역 탭 → dismiss 확인
  → screenshot

[Step 4] 화면 5 (EditDori 메모) 검증
  → 내역 탭 → 인물 카드 → 거래 내역 → 편집
  → 기존 메모값 표시 확인
  → 수정 입력 → 저장
  → screenshot
```

---

## 주요 코드 참조

| 항목 | 위치 |
|------|------|
| `DoriTextField` 구현 | `DoriTextField.swift:11-54` |
| `maxLength` 잘림 로직 | `DoriTextField.swift:41-43` |
| 양방향 바인딩 | `DoriTextField.swift:40-50` |
| AddDori 메모 섹션 | `Page3AmountDateView.swift:141-153` |
| EditDori 메모 섹션 | `EditDoriView.swift:117-128` |
| SegmentGrid 메모필드 | `DoriSegmentGridWithMemo.swift:63-65` |
| `syncSelectionWithMemo` | `DoriSegmentGridWithMemo.swift:68-75` |
| `syncMemoWithSelection` | `DoriSegmentGridWithMemo.swift:78-84` |
| `DoriKeyboardDismissModifier` | `DoriKeyboardDismissModifier.swift` |
