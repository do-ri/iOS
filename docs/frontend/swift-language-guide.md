# Swift Language Guide

## Stable Rules

- 동시성 경계를 지나는 타입은 가능한 한 `Sendable`로 드러낸다.
- UI 상태와 사용자 상호작용 해석은 메인 액터 규칙을 따른다.
- 안전성을 설명할 수 없는 동시성 우회는 도입하지 않는다.

## Project Assumption

- 이 프로젝트는 Swift 6 동시성 규칙을 전제로 한다.
- 타입 선언에서 안전성을 먼저 표현하고, 구현에서는 그 계약을 지킨다.

## Documentation Rule

이 문서는 특정 모델 예시보다 동시성에 대한 팀의 판단 기준만 남긴다.
