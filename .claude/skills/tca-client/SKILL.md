---
name: tca-client
description: TCA @Dependency Client를 생성한다. 서비스명+엔드포인트만 변경하면 되는 boilerplate 자동 생성.
---

# TCA Dependency Client 생성

사용자가 요청한 서비스에 대한 TCA `@Dependency` Client를 생성한다.

## 지침

1. `docs/GUIDE.md` 지침서를 읽고 프로젝트 컨텍스트를 파악한다
2. 기존 Client 코드가 있는지 `Core/Clients/` 디렉토리를 확인한다
3. 아래 템플릿을 기반으로 Client 정의, Live 구현, Mock 구현 파일을 생성한다

## 템플릿: Client 정의

```swift
// {Service}Client.swift
import ComposableArchitecture
import Foundation

@DependencyClient
struct {Service}Client: Sendable {
    var fetch: @Sendable () async throws -> [Item]
    var get: @Sendable (_ id: UUID) async throws -> Item
    var create: @Sendable (_ item: Item) async throws -> Item
    var update: @Sendable (_ item: Item) async throws -> Item
    var delete: @Sendable (_ id: UUID) async throws -> Void
}

extension {Service}Client: TestDependencyKey {
    static let previewValue = Self(
        fetch: { [.mock] },
        get: { _ in .mock },
        create: { $0 },
        update: { $0 },
        delete: { _ in }
    )

    static let testValue = Self()
}

extension DependencyValues {
    var {service}Client: {Service}Client {
        get { self[{Service}Client.self] }
        set { self[{Service}Client.self] = newValue }
    }
}
```

## 템플릿: Live 구현

```swift
// {Service}Client+Live.swift
import ComposableArchitecture
import Foundation

extension {Service}Client: DependencyKey {
    static let liveValue = Self(
        fetch: {
            // URLSession 기반 실제 API 호출
            let (data, _) = try await URLSession.shared.data(
                from: URL(string: "https://api.example.com/items")!
            )
            return try JSONDecoder().decode([Item].self, from: data)
        },
        get: { id in
            let (data, _) = try await URLSession.shared.data(
                from: URL(string: "https://api.example.com/items/\(id)")!
            )
            return try JSONDecoder().decode(Item.self, from: data)
        },
        create: { item in
            // POST 요청 구현
            item
        },
        update: { item in
            // PUT 요청 구현
            item
        },
        delete: { id in
            // DELETE 요청 구현
        }
    )
}
```

## 템플릿: Mock 구현 (서버 API 스펙 전달 전 사용)

```swift
// {Service}Client+Mock.swift
import ComposableArchitecture
import Foundation

extension {Service}Client {
    static let mock = Self(
        fetch: {
            // MockDataService에서 가져온 샘플 데이터 반환
            []
        },
        get: { _ in
            .mock
        },
        create: { $0 },
        update: { $0 },
        delete: { _ in }
    )
}
```

## 규칙

- Client 이름: `{Service}Client` (예: `DataClient`, `KeychainClient`, `KakaoAuthClient`)
- struct은 `Sendable` 준수 필수
- 모든 closure 프로퍼티는 `@Sendable` 어노테이션
- `@unchecked Sendable` 사용 금지
- `@DependencyClient` 매크로가 unimplemented 기본값 init을 생성하므로 `testValue = Self()`로 간단히 선언 가능
- `liveValue`, `previewValue`, `testValue` 3단 분리

## 파일 위치

```
Dori-iOS/Core/Clients/
  {Service}Client.swift         → Client 정의 + TestDependencyKey + DependencyValues
  {Service}Client+Live.swift    → DependencyKey (liveValue)
  {Service}Client+Mock.swift    → Mock 구현 (개발용)
```

## 프로젝트 주요 Client 목록

| Client | 역할 |
|--------|------|
| `DataClient` | 경조사 데이터 CRUD (Person, Transaction) |
| `KeychainClient` | 토큰 저장/조회/삭제 |
| `KakaoAuthClient` | 카카오 로그인/로그아웃/회원탈퇴 |
