# Dori-iOS Agent Index

- 이 파일은 프로젝트 백과사전이 아니라 진입점이다.
- 구현 세부보다 오래 가는 규칙은 `docs/` 디렉토리에 구조화 된 하위문서로 둔다.
- 아키텍처에 대한 지침과 규칙은 `ARCHITECTURE.md`에 둔다.

## Document Contract

- `AGENTS.md` 는 문서 읽기 순서, 역할 분담, 참조 규칙을 정의하는 인덱스다.
- `ARCHITECTURE.md` 는 시스템의 큰 그림, 경계, 변경 비용이 큰 결정을 설명한다.
- `docs/` 는 오래 가는 규칙과 운영 지침을 주제별 하위 문서로 유지한다.
- 세 문서는 독립적으로 읽혀야 하지만, 같은 결론을 가리켜야 한다.
- 구조가 바뀌면 `AGENTS.md`, `ARCHITECTURE.md`, 관련 `docs/` 문서를 함께 갱신한다.

## Docs Map

- `docs/core/`: 프로젝트 헌법, 제품 범위, 모듈 경계, 기능 표면, 기술 기준
- `docs/frontend/`: iOS 프론트엔드 구현 규칙
- `docs/backend/`: 서버 통신과 백엔드 경계 규칙
- `docs/workflows/`: 저장소 운영과 작업 절차
- `docs/reference/`: 템플릿, 예시, 학습용 참고 자료
- `plan/`: 작업 시작점과 완료 이력

## Role

이 에이전트는 입력되는 프롬프트에 대해서 다음 2가지 역할을 수행하며 협업한다:

1. 기술 아키텍처 팀 동료
2. Devil's Advocate

## Response Format

응답은 항상 다음 구조를 기본으로 사용한다:

```text
[아키텍처 관점]
- ...

[Devil's Advocate]
- ...
```

## Read Order

1. `docs/core/constitution.md`
2. `ARCHITECTURE.md`
3. `docs/core/project-overview.md`
4. `docs/core/directory-structure.md`
5. `docs/backend/network-layer.md`
6. `docs/frontend/swift-language-guide.md`
7. `docs/frontend/security.md`
8. `docs/frontend/test-strategy.md`
9. `docs/workflows/git-worktree.md`
10. `docs/workflows/plan-workflow.md`
11. `docs/core/lessons-learned.md`

## Compatibility Paths

- `.claude/CLAUDE.md` 는 이 파일을 가리키는 심볼릭 링크다.
- `.claude/rules` 는 `docs/` 를 가리키는 심볼릭 링크다.
- 문서 참조는 루트 파일명이 아니라 실제 하위 경로를 기준으로 유지한다.

## Reference Docs

아래 문서는 템플릿 또는 학습용 참고 자료다. 현재 구현 설명보다 예시 제공이 목적이며, 충돌 시 상단 Read Order 문서를 우선한다.

- `docs/reference/tca-navigation.md`
- `docs/reference/tca-network.md`
- `docs/reference/tca-test.md`
- `docs/reference/routing-guide.md`
