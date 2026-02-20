---
name: pr-create
description: GitHub PR을 생성한다. 템플릿을 읽고 커밋 히스토리 기반으로 본문을 자동 생성.
---

# GitHub Pull Request 생성

GitHub PR 템플릿(`.github/PULL_REQUEST_TEMPLATE.md`)을 읽고, 현재 브랜치의 커밋 히스토리를 분석하여 템플릿 구조에 맞는 PR을 자동 생성한다.

## 언제 사용하는가?

✅ **사용해야 하는 경우:**
- 사용자가 "PR 올려줘", "PR 만들어줘", "풀리퀘 생성" 등을 요청할 때
- Feature 개발 완료 후 develop 브랜치로 머지하기 위한 PR 생성
- 커밋이 완료되고 push까지 완료된 상태

❌ **사용하지 않아야 하는 경우:**
- 아직 커밋하지 않은 변경사항이 있는 경우 (먼저 커밋 필요)
- 브랜치를 push하지 않은 경우 (먼저 push 필요)
- hotfix나 긴급 수정으로 직접 PR 본문을 작성해야 하는 경우

## 지침

### 1단계: PR 템플릿 확인

프로젝트에 `.github/PULL_REQUEST_TEMPLATE.md` 파일이 있는지 확인한다:

```bash
ls -la .github/PULL_REQUEST_TEMPLATE.md
```

- **템플릿이 있는 경우**: 템플릿 구조를 따라 본문 생성
- **템플릿이 없는 경우**: 기본 포맷으로 본문 생성

### 2단계: Git 정보 수집

현재 브랜치의 정보를 수집한다:

```bash
# 현재 브랜치 이름
git branch --show-current

# base 브랜치와의 차이 (develop 또는 main)
git log develop..HEAD --oneline
# 또는
git log main..HEAD --oneline

# 변경된 파일 목록
git diff develop...HEAD --stat
# 또는
git diff main...HEAD --stat
```

### 3단계: 이슈 번호 추출

브랜치 이름에서 이슈 번호를 추출한다:

**브랜치 네이밍 패턴**: `feature/{issue}-{desc}` 또는 `fix/{issue}-{desc}`

예시:
- `feature/16-add-dori` → 이슈 번호: `#16`
- `fix/24-login-bug` → 이슈 번호: `#24`

### 4단계: PR 제목 생성

브랜치 타입과 설명을 기반으로 제목을 생성한다:

| 브랜치 타입 | PR 제목 패턴 |
|------------|-------------|
| `feature/*` | `[Feature] {기능 설명}` |
| `fix/*` | `[Fix] {수정 내용}` |
| `chore/*` | `[Chore] {작업 내용}` |
| `refactor/*` | `[Refactor] {리팩토링 내용}` |

### 5단계: PR 본문 생성

#### Dori-iOS 템플릿 구조

```markdown
## About this PR
### ⚓ Related Issue
- #{이슈번호}

### 🥥 Contents
{커밋 히스토리 기반 작업 내용 요약}

**주요 변경사항:**
- {변경사항 1}
- {변경사항 2}
- {변경사항 3}

### 📸 Screenshot
{UI 변경이 있는 경우 스크린샷 테이블, 없으면 "UI 변경 없음"}

## Other information 🔥
{리뷰어가 참고할 내용, 특이사항}
```

#### 본문 생성 규칙

1. **Related Issue**: 브랜치에서 추출한 이슈 번호
2. **Contents**:
   - 커밋 메시지들을 분석하여 작업 내용 요약
   - 주요 변경사항은 커밋 제목 기반으로 bullet point 작성
3. **Screenshot**:
   - Feature/UI 작업인 경우: 빈 테이블 제공 (사용자가 수동 추가)
   - 그 외: "UI 변경 없음" 또는 섹션 제거
4. **Other information**:
   - 논리적 커밋 분리 여부
   - 테스트 상태
   - 서버 API 연동 대기 여부 등

### 6단계: PR 생성 실행

```bash
gh pr create \
  --title "{PR 제목}" \
  --body "$(cat <<'EOF'
{생성한 본문}
EOF
)" \
  --base develop \
  --head {현재 브랜치}
```

**주의사항:**
- base 브랜치는 일반적으로 `develop` (Git 전략 참조)
- hotfix는 `main`으로 직접 PR 생성 가능
- PR 생성 후 URL을 사용자에게 반환

### 7단계: PR 생성 확인

```bash
# 생성된 PR 확인
gh pr view --web
```

## 템플릿 예시

### Dori-iOS 프로젝트 PR 본문 예시

```markdown
## About this PR
### ⚓ Related Issue
- #16

### 🥥 Contents
경조사 내역(주도리/받도리) 추가 및 수정 기능을 TCA 아키텍처로 구현했습니다.

**주요 변경사항:**
- **네트워크 레이어**: DoriEndpoints, Requests/Responses 추가
- **Core 모델**: DoriDomain 모델 정의, 캘린더 아이콘 추가
- **AddDori Feature**: 3-step 상태 관리 (관계인 검색 → 방문 여부 → 상세 입력)
- **API Client**: AddDoriAPIClient (관계인 검색, 내역 등록/수정)
- **UI Components**: 14개 파일 (StepIndicator, PartnerSearch, DetailInput 등)
- **테스트**: AddDoriFeatureTests (TCA TestStore 기반)

**커밋 히스토리:**
- `chore: AddDori 네트워크 레이어 추가`
- `chore: AddDori Core/DesignSystem 업데이트`
- `feat: AddDori 내역 추가/수정 Feature 구현`
- `test: AddDori Reducer 테스트 추가`

### 📸 Screenshot
|Step 1: 관계인 검색|Step 2: 방문 여부|Step 3: 상세 정보|
|--|--|--|
|<img width="300" alt="" src="">|<img width="300" alt="" src="">|<img width="300" alt="" src="">|

## Other information 🔥
- 네트워크/Core/Feature/Test로 논리적 커밋 분리 완료
- Mock API로 개발, 서버 API 연동 대기 중
- TCA TestStore 기반 단위 테스트 포함
```

## 자동화 플로우

```
1. 브랜치 정보 수집
   ↓
2. 템플릿 읽기
   ↓
3. 커밋 히스토리 분석
   ↓
4. PR 본문 조립
   ↓
5. gh pr create 실행
   ↓
6. PR URL 반환
```

## 주의사항

- **Push 확인**: PR 생성 전에 브랜치가 remote에 push되어 있어야 함
- **base 브랜치**: 일반적으로 `develop`, hotfix는 `main`
- **스크린샷**: UI 작업인 경우 빈 테이블 제공, 사용자가 수동으로 업로드
- **Co-Authored-By**: 커밋에는 포함되지만 PR 본문에는 불필요
- **Draft PR**: 작업 중인 경우 `--draft` 옵션 사용 가능

## 오류 처리

| 오류 | 원인 | 해결 |
|------|------|------|
| `head branch not found` | 브랜치를 push하지 않음 | `git push -u origin {브랜치명}` |
| `pull request already exists` | 이미 PR이 존재 | `gh pr view`로 확인 |
| `base branch not found` | base 브랜치 오타 | develop/main 확인 |

## 확장 기능

- **Draft PR**: `--draft` 옵션으로 작업 중 PR 생성
- **Reviewer 지정**: `--reviewer {username}` 옵션
- **Label 추가**: `--label feature,tca` 등
- **Assignee 설정**: `--assignee @me`
