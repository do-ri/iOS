# Dori-iOS Agent Index

이 파일은 프로젝트 백과사전이 아니라 진입점이다. 구현 세부보다 오래 가는 규칙은 `docs/constitution.md`와 `ARCHITECTURE.md`에 둔다.

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

1. `docs/constitution.md`
2. `ARCHITECTURE.md`
3. `docs/project-overview.md`
4. `docs/directory-structure.md`
5. `docs/network-layer.md`
6. `docs/swift-language-guide.md`
7. `docs/frontend/security.md`
8. `docs/frontend/test-strategy.md`
9. `docs/git-worktree.md`
10. `docs/lessons-learned.md`

## Compatibility Paths

- `.claude/CLAUDE.md` 는 이 파일을 가리키는 심볼릭 링크다.
- `.claude/rules` 는 `docs/` 를 가리키는 심볼릭 링크다.
- 기존 `@rules/...`, `@network-layer.md`, `@swift-language-guide.md` 참조는 계속 동작해야 한다.

## Reference Docs

아래 문서는 템플릿 또는 학습용 참고 자료다. 현재 구현 설명보다 예시 제공이 목적이며, 충돌 시 상단 Read Order 문서를 우선한다.

- `docs/tca-navigation.md`
- `docs/tca-network.md`
- `docs/tca-test.md`
- `docs/routing-guide.md`
