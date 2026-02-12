### 5.1 설계 원칙

- API Client를 TCA `@Dependency`로 정의 (인터페이스 우선 설계)
- 서버 API 스펙 전달 전까지 **Mock 구현**으로 개발 진행
- `liveValue` / `previewValue` / `testValue` 3단 분리

### 5.2 API Client 구조

```swift
@DependencyClient
struct DataClient: Sendable {
    var fetchPersons: @Sendable () async throws -> [Person]
    var fetchPerson: @Sendable (UUID) async throws -> Person
    var fetchTransactions: @Sendable (Date, TransactionType?) async throws -> [Transaction]
    var deletePerson: @Sendable (UUID) async throws -> Void
    // ... CRUD 메서드 추가
}
```

### 5.3 에러 핸들링

```swift
enum APIError: Error, Equatable, Sendable {
    case networkError(String)
    case decodingError
    case unauthorized
    case serverError(Int)
    case unknown
}
```

### 5.4 코드 패턴

`/tca-network` skill 참조