# Directory Structure

## Top-Level Modules

- `Projects/App`: 앱 부트스트랩과 dependency 조합
- `Projects/Feature`: 사용자 흐름과 화면 상태
- `Projects/Core`: 도메인 모델과 디자인 시스템
- `Projects/Platform`: SDK 및 저장소 어댑터
- `Projects/Infra`: 네트워크와 인프라 구현
- `docs`: 프로젝트 규칙과 참고 문서
- `plan`: 작업 시작 문서와 완료 이력

## Boundary Rules

- `App`은 조합한다.
- `Feature`는 흐름을 해석한다.
- `Core`는 공용 언어를 제공한다.
- `Platform`과 `Infra`는 외부 시스템과 통신한다.

## What To Preserve

- Feature가 외부 구현 세부를 직접 소유하지 않게 할 것
- 인증, 네트워크, 저장소 같은 횡단 관심사를 중앙 경계에 둘 것
- 문서 구조도 코드 경계를 따라갈 것
- 작업 시작점과 완료 이력을 분리할 것
