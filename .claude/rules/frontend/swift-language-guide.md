### Swift Concurrency 규칙

- 도메인 모델: `Sendable` 준수
- 격리가 논리적으로 보장된다면 Sendable 키워드 사용
- `@unchecked Sendable` NSLock 등 개념적으로 잘 구현된 경우가 아니라면 **사용 금지**
| Dependency Client struct | `Sendable` 준수 |
| Client closure 프로퍼티 | `@Sendable` 어노테이션 |


### 도메인 모델 작성 예시
- Decoding -> Decoable
- Encoding -> Encodable
- Decoding & Encoding -> Codable
- domain 격리 보장시 -> Sendable
- UI에 사용 시 -> Hashable, Identifiable 등 UI가 요구하는 프로토콜

```swift
struct Person: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var name: String
    var relationship: Relationship
    var transactions: [Transaction]
}
```