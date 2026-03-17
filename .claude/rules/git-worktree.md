# Git Worktree 워크플로우

## 구조 원칙

워크트리는 반드시 **메인 레포와 형제(sibling) 폴더**로 생성한다.

```
Dori-Workspace/          ← git 미관리 폴더 (절대 git init 금지)
  Dori-iOS/              ← main worktree (git repo 본체)
  Dori-iOS-develop/      ← worktree: develop
  Dori-iOS-feature31/    ← worktree: feature/31-...
  Dori-iOS-fix32/        ← worktree: fix/32-...
  Dori-iOS-fix34/        ← worktree: fix/34-...
```

**핵심 규칙**: `Dori-iOS` 폴더 **내부**에 워크트리를 생성하지 않는다.

---

## 워크트리 추가

반드시 **`Dori-iOS` 디렉토리 안에서** 실행한다.

```bash
cd ~/Desktop/Dori-Workspace/Dori-iOS

# ../  가 핵심 — 한 단계 위(Dori-Workspace)에 생성
git worktree add ../Dori-iOS-feature31 feature/31-custom-navigationBar
git worktree add ../Dori-iOS-fix32 fix/32-textfield-validation
git worktree add ../Dori-iOS-develop develop
```

### 네이밍 규칙

| 브랜치 | 워크트리 폴더명 |
|--------|----------------|
| `develop` | `Dori-iOS-develop` |
| `feature/{n}-{desc}` | `Dori-iOS-feature{n}` |
| `fix/{n}-{desc}` | `Dori-iOS-fix{n}` |

---

## 워크트리 제거

```bash
cd ~/Desktop/Dori-Workspace/Dori-iOS

# 1. 워크트리 제거 (폴더도 함께 삭제됨)
git worktree remove ../Dori-iOS-feature31

# 2. 고아 참조 정리
git worktree prune

# 3. (선택) 브랜치도 삭제
git branch -d feature/31-custom-navigationBar
```

### 강제 제거 (미커밋 변경사항이 있을 때)

```bash
git worktree remove --force ../Dori-iOS-feature31
```

---

## 현재 워크트리 확인

```bash
git worktree list
```

---

## 자주 하는 실수

| ❌ 잘못된 사용 | ✅ 올바른 사용 |
|---------------|---------------|
| `Dori-Workspace`에서 `git worktree add` 실행 | `Dori-iOS` 안에서 실행 |
| `git worktree add Dori-iOS-feature31 ...` (상대경로, `../` 없음) | `git worktree add ../Dori-iOS-feature31 ...` |
| `Dori-Workspace`에 `git init` | 절대 하지 않음 |
| 메인 레포 내부에 워크트리 생성 | 형제 폴더로 생성 |
