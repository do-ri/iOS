### 10.1 Reducer 테스트

- TCA `TestStore`를 사용하여 Reducer 로직을 검증한다
- `withDependencies`로 Mock 의존성을 주입한다
- `store.send()` → State 변경 검증
- `store.receive()` → Effect 결과 검증
- 코드 패턴: `/tca-test` skill 참조

### 10.2 유틸리티 테스트

- `Date+Extensions`, `Int+Extensions` 등 Extension 유틸 함수 단위 테스트