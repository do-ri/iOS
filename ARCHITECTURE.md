# Dori-iOS Architecture

이 문서는 현재 코드베이스의 구조를 설명한다. 세부 구현보다 시스템 모양, 경계, 책임 분리를 우선한다.

이 문서 구성은 matklad의 `ARCHITECTURE.md`와 rust-analyzer의 architecture 문서처럼, 큰 그림과 변경 비용이 큰 경계를 먼저 설명하는 방식을 따른다.

## 1. System Shape

Dori-iOS는 TCA 기반 iOS 클라이언트다. 앱은 인증 상태를 확인한 뒤 온보딩 또는 메인 경험으로 진입하고, 각 화면은 독립 Feature가 상태를 소유한다.

고수준 흐름은 다음과 같다.

```text
User intent
  -> View
  -> Feature Action
  -> Reducer
  -> State / Effect
  -> Client boundary
  -> Platform or Infra
  -> Result
  -> Reducer
  -> Updated state
  -> View
```

## 2. App Topology

현재 루트 구조는 세 단계다.

```text
AppFeature
  -> splash
  -> intro
  -> mainTab
```

- `Splash`는 진입 여부를 판단한다.
- `Intro`는 로그인 시작을 담당한다.
- `MainTab`은 실제 앱 기능을 조합한다.

이 구조에서 인증 여부 판단과 메인 경험 진입은 루트가 소유한다.

## 3. Navigation Model

현재 프로젝트는 한 가지 패턴만 고집하지 않고 화면 성격에 따라 섞어 쓴다.

- 루트 전환은 명시적 route 상태로 제어한다.
- History 탭은 stack navigation을 사용한다.
- Calendar는 생성 흐름을 presentation 상태로 띄운다.
- MyPage는 자체 navigation path를 가진다.
- MainTab은 시스템 `TabView` 대신 앱 전용 탭바 컴포넌트로 화면을 교체한다.

중요한 점은, 어떤 네비게이션 도구를 쓰든 전환 결정이 Feature 상태에서 설명 가능해야 한다는 것이다.

## 4. Module Boundaries

### App

- 앱 부트스트랩
- dependency 조합
- 루트 route 소유

### Feature

- 사용자 흐름
- 화면 상태
- 화면 간 delegate와 path 조합

### Core

- 도메인 모델
- 공통 의존성 키
- 디자인 시스템

### Platform

- Kakao SDK
- Keychain
- iOS 런타임에 가까운 어댑터

### Infra

- 네트워크 서비스 구현
- 인증 인터셉터
- 로깅과 요청 파이프라인

## 5. Dependency Strategy

- Feature는 `@Dependency`를 통해 외부 기능에 접근한다.
- 외부 연동은 feature-specific client로 노출될 수 있고, 공통 네트워크 파이프라인은 Infra에서 담당한다.
- 앱 조합 시점에서 live 구현을 주입한다.

이 프로젝트에서 중요한 것은 "클라이언트 이름 통일"이 아니라 "외부 시스템 세부가 Feature 안으로 새지 않는 것"이다.

## 6. Authentication Architecture

인증은 화면 하나의 책임이 아니라 앱 전역 정책이다.

- Splash는 토큰 존재 기반 진입 판단을 담당한다.
- Intro는 Kakao 로그인과 서버 로그인 시작을 담당한다.
- 토큰 보관은 저장소 경계에서 수행한다.
- 네트워크 인증 실패와 refresh 재시도는 인터셉터가 담당한다.
- refresh 실패 시 강제 로그아웃은 루트로 전파된다.

즉, 인증은 UI, 저장소, 네트워크가 한 흐름으로 연결된 구조다.

## 7. Stable Invariants

- View는 외부 시스템 세부를 직접 다루지 않는다.
- Feature 간 직접 결합보다 부모 조합을 우선한다.
- 인증 실패 처리는 중앙 경계에서 설명 가능해야 한다.
- 현재 화면 구조는 모듈 경계를 흐리지 않는 선에서만 확장한다.
- 문서는 구현 예시보다 구조 규칙을 우선한다.

## 8. Related Docs

- `docs/constitution.md`
- `docs/project-overview.md`
- `docs/directory-structure.md`
- `docs/network-layer.md`
- `docs/swift-language-guide.md`
