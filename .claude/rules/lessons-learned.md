# Lessons Learned (실수 방지 가이드)

이 파일은 개발 중 발생한 문제와 해결책을 기록하여 같은 실수를 반복하지 않기 위한 문서입니다.

---

## 1. 토큰 검증 전략 (2026-02-25)

### ❌ 잘못된 접근: 클라이언트에서 JWT 만료 시간 체크

```swift
// 하지 말 것!
let expirationDate = Date(timeIntervalSince1970: exp)
let now = Date()  // 디바이스 로컬 시간

if expirationDate <= now {
  // 만료됨으로 판단 → refresh 시도
}
```

**문제점**:
- 디바이스 시간 조작 가능
- 서버와 클라이언트 시간 불일치
- 시간대 변경 시 오류
- 과도한 복잡도

### ✅ 올바른 접근: 서버가 판단, 클라이언트는 반응

```swift
// Splash에서
case .isAppeared:
  let hasToken = (try? tokenStore.exists()) ?? false

  if hasToken {
    // 바로 진입 (만료 여부 체크 안 함)
    await send(.delegate(.authenticated))
  } else {
    await send(.delegate(.unauthenticated))
  }

// AuthInterceptor에서
public func retry(...) {
  guard response.statusCode == 401 else { return }

  // 서버가 401 보냄 → 이제 refresh
  let success = await refreshTokens()
  if success {
    completion(.retry)  // 원래 요청 재시도
  }
}
```

**핵심**:
- **서버만이 토큰 만료를 정확히 판단할 수 있음**
- 클라이언트는 401 응답에 반응만
- RefreshCoordinator가 중복 refresh 방지
- 가장 단순하고 안전

**참고 프로젝트**: Hambug 앱 (실제 운영 검증됨)

---

## 2. AuthInterceptor의 별도 Session (2026-02-25)

### 왜 필요한가?

```swift
public final class AuthInterceptor: RequestInterceptor {
  private let session: Session  // ← 별도 Session 필수!

  public init(tokenStore: any AuthTokenStoring) {
    self.session = Session()  // interceptor 없음
  }

  private func refreshTokens() async -> Bool {
    // 이 session은 interceptor가 없음
    let response = try await session.request(request)
    // adapt 호출 안 됨 → 무한 루프 방지 ✅
  }
}
```

**필요한 이유**:
1. **무한 루프 방지**: refresh 요청에 interceptor 적용되면 안 됨
2. **순환 참조 방지**: NetworkService ↔ AuthInterceptor

**구조**:
```
메인 Session (interceptor O)  → 일반 API용
AuthInterceptor 내부 Session (interceptor X)  → refresh 전용
```

---

## 3. Splash에서 TokenRefreshClient 사용 금지 (2026-02-25)

### ❌ 문제가 있었던 코드

```swift
// Splash에서
if hasToken {
  // 메인 networkService로 refresh 시도
  let isValid = try await tokenRefreshClient.validateAndRefresh()
  // → 메인 networkService 사용
  // → AuthInterceptor.adapt 호출
  // → 만료된 access token 추가
  // → 401 실패!
}
```

### ✅ 해결책

```swift
// Splash에서
if hasToken {
  // refresh 시도 안 함!
  await send(.delegate(.authenticated))
}

// MainTab 진입 후 첫 API 호출 시
// → 401 발생
// → AuthInterceptor.retry → refresh
// → 성공 ✅
```

**핵심**:
- Splash에서는 토큰 존재만 체크
- refresh는 AuthInterceptor가 자동 처리
- 단순하고 안전

---

## 4. RefreshCoordinator의 역할 (2026-02-25)

### 중복 refresh 방지

```swift
private actor RefreshCoordinator {
  private var refreshTask: Task<Bool, Never>?

  func refresh(with refreshTokens: @escaping @Sendable () async -> Bool) async -> Bool {
    if let existingTask = refreshTask {
      return await existingTask.value  // 이미 진행 중이면 기다림
    }

    let task = Task { await refreshTokens() }
    refreshTask = task
    let result = await task.value
    refreshTask = nil

    return result
  }
}
```

**시나리오**:
```
MainTab 진입 → 3개 API 동시 호출 → 모두 401
  ↓
Calendar: AuthInterceptor.retry → RefreshCoordinator
History: AuthInterceptor.retry → RefreshCoordinator (기다림)
MyPage: AuthInterceptor.retry → RefreshCoordinator (기다림)
  ↓
1번만 refresh 실행 ✅
  ↓
3개 모두 재시도 → 성공
```

**핵심**: 여러 API가 동시에 실패해도 refresh는 1번만

---

## 5. 아키텍처 결정 시 참고

### 다른 프로젝트 패턴 검증

**Hambug 프로젝트**:
- Splash: 토큰 존재만 체크
- refresh: AuthInterceptor에서만 처리
- 실제 운영 검증됨

**교훈**:
- 실제 운영 중인 앱의 패턴을 참고하면 검증된 솔루션을 얻을 수 있음
- 과도한 최적화보다 단순하고 검증된 방법이 더 안전

---

## 요약

| 항목 | ❌ 하지 말 것 | ✅ 해야 할 것 |
|------|-------------|-------------|
| **토큰 검증** | 클라이언트에서 만료 시간 체크 | 서버 401 응답에 반응 |
| **Splash** | refresh 시도 | 토큰 존재만 체크 |
| **AuthInterceptor** | 메인 Session 사용 | 별도 Session 사용 |
| **복잡도** | 과도한 최적화 | 단순하고 검증된 방법 |

---

**업데이트 일자**: 2026-02-25
**관련 이슈**: 자동 로그인 기능 구현
