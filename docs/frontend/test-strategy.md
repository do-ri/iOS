# Test Strategy

## Stable Rules

- 테스트는 상태 전이와 경계 동작을 우선 검증한다.
- 외부 의존성은 대체 가능해야 한다.
- navigation과 인증처럼 깨지기 쉬운 흐름은 Reducer 수준에서 검증 가능해야 한다.

## Secondary Rules

- 순수 변환 로직과 유틸리티는 단위 테스트로 분리한다.
- UI 예시보다 사용자 흐름의 상태 변화를 먼저 검증한다.

## Reference

- `docs/reference/tca-test.md`
