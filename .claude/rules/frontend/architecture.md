### 3.1 TCA 단방향 데이터 플로우

- 각 화면 = 1개 `@Reducer` + 1개 SwiftUI `View`
- 상태 변경은 반드시 Action → Reducer → State 경로를 따른다
- Side Effect는 `Effect<Action>`으로 관리한다

### 3.2 Navigation 전략

| 범위 | 방식 | 설명 |
|------|------|------|
| App Root | Tree-based | `enum State`로 Intro / MainTab 분기 |
| Tab 내부 (History) | Stack-based | `StackState` / `StackAction`로 list → detail push |
| 모달/시트 | Tree-based | `@Presents` / `ifLet`으로 모달 표시 |

### 3.3 의존성 관리

- TCA `@Dependency` 시스템 사용
- Protocol 대신 **struct + closure** 패턴 (`DependencyKey` 준수)
- `liveValue` / `previewValue` / `testValue` 3단 분리

### 3.4 코드 패턴 참조

**자동화 스킬** (boilerplate 생성용):

| Skill | 용도 |
|-------|------|
| `/tca-reducer` | @Reducer 구조 생성 |
| `/tca-view` | TCA Store 연결 SwiftUI View |
| `/tca-client` | @Dependency Client 구조 |

**레퍼런스 문서** (분기/도메인 지식 필요):

| 문서 | 용도 |
|------|------|
| `docs/tca-navigation.md` | Tree/Stack/Tab/AppRoot Navigation 패턴 |
| `docs/tca-test.md` | TestStore 기반 테스트 패턴 |
| `docs/tca-network.md` | API Client + 에러 핸들링 |
