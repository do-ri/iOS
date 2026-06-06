# Network Layer

## Principles

- Feature는 네트워크 세부를 직접 다루지 않는다.
- 앱 조합 시점에서 live client를 주입한다.
- 공통 인증 정책은 인터셉터와 저장소 경계에서 처리한다.
- 화면은 요청의 목적과 결과만 알고, 전송 방식과 refresh 절차는 몰라야 한다.

## Current Shape

현재 프로젝트는 feature-specific client와 공통 네트워크 파이프라인을 함께 사용한다.

- Feature 계층: 기능별 client
- Infra 계층: `NetworkService`, interceptor, logger
- Platform / storage 계층: 토큰 저장소

## Stable Rules

- 인증 실패와 refresh 재시도는 중앙 네트워크 경계에서 설명 가능해야 한다.
- 토큰 저장과 삭제는 저장소 경계에서 수행한다.
- 네트워크 구조를 바꾸면 인증 문서와 앱 부트스트랩 문서도 같이 바꾼다.

## Related Docs

- `ARCHITECTURE.md`
- `docs/core/lessons-learned.md`
- `docs/reference/tca-network.md`
