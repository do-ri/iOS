# TCA Network API Client 레퍼런스

API Client를 TCA `@Dependency` 패턴으로 생성할 때 참조하는 문서. Live/Mock 구현은 API 스펙에 의존하므로 도메인에 맞게 조정한다.

## 참조

- `docs/GUIDE.md` 지침서의 네트워크 레이어 섹션을 함께 참고한다
- `.claude/skills/tca-client/SKILL.md` — 기본 Client 골격 생성 스킬

---

## 템플릿: API 에러 타입

```swift
// Core/Clients/APIError.swift
import Foundation

enum APIError: Error, Equatable, Sendable {
    case networkError(String)
    case decodingError
    case unauthorized
    case serverError(Int)
    case unknown

    var localizedDescription: String {
        switch self {
        case let .networkError(message):
            return message
        case .decodingError:
            return "데이터를 처리할 수 없습니다."
        case .unauthorized:
            return "인증이 만료되었습니다. 다시 로그인해주세요."
        case let .serverError(code):
            return "서버 오류가 발생했습니다. (코드: \(code))"
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
```

## 템플릿: API 기본 설정

```swift
// Core/Clients/APIConfig.swift
import Foundation

enum APIConfig {
    static let baseURL = URL(string: "https://api.example.com")!

    enum Path {
        static let persons = "/persons"
        static let transactions = "/transactions"
        static let auth = "/auth"
    }
}
```

## 템플릿: API Client 정의

```swift
// Core/Clients/DataClient.swift
import ComposableArchitecture
import Foundation

@DependencyClient
struct DataClient: Sendable {
    // Person CRUD
    var fetchPersons: @Sendable () async throws -> [Person]
    var fetchPerson: @Sendable (_ id: UUID) async throws -> Person
    var createPerson: @Sendable (_ person: Person) async throws -> Person
    var updatePerson: @Sendable (_ person: Person) async throws -> Person
    var deletePerson: @Sendable (_ id: UUID) async throws -> Void

    // Transaction CRUD
    var fetchTransactions: @Sendable (_ date: Date, _ type: TransactionType?) async throws -> [Transaction]
    var createTransaction: @Sendable (_ personID: UUID, _ transaction: Transaction) async throws -> Transaction
    var updateTransaction: @Sendable (_ transaction: Transaction) async throws -> Transaction
    var deleteTransaction: @Sendable (_ id: UUID) async throws -> Void
}

extension DataClient: TestDependencyKey {
    static let previewValue = Self(
        fetchPersons: { Person.mockList },
        fetchPerson: { _ in .mock },
        createPerson: { $0 },
        updatePerson: { $0 },
        deletePerson: { _ in },
        fetchTransactions: { _, _ in Transaction.mockList },
        createTransaction: { _, t in t },
        updateTransaction: { $0 },
        deleteTransaction: { _ in }
    )

    static let testValue = Self()
}

extension DependencyValues {
    var dataClient: DataClient {
        get { self[DataClient.self] }
        set { self[DataClient.self] = newValue }
    }
}
```

## 템플릿: Live 구현 (URLSession)

```swift
// Core/Clients/DataClient+Live.swift
import ComposableArchitecture
import Foundation

extension DataClient: DependencyKey {
    static let liveValue: Self = {
        let decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return decoder
        }()

        let encoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            return encoder
        }()

        @Sendable
        func request<T: Decodable>(
            path: String,
            method: String = "GET",
            body: (any Encodable)? = nil
        ) async throws -> T {
            var urlRequest = URLRequest(
                url: APIConfig.baseURL.appendingPathComponent(path)
            )
            urlRequest.httpMethod = method
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // Keychain에서 토큰을 가져와 Authorization 헤더 설정
            // urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            if let body {
                urlRequest.httpBody = try encoder.encode(body)
            }

            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }

            switch httpResponse.statusCode {
            case 200..<300:
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw APIError.decodingError
                }
            case 401:
                throw APIError.unauthorized
            default:
                throw APIError.serverError(httpResponse.statusCode)
            }
        }

        return Self(
            fetchPersons: {
                try await request(path: APIConfig.Path.persons)
            },
            fetchPerson: { id in
                try await request(path: "\(APIConfig.Path.persons)/\(id)")
            },
            createPerson: { person in
                try await request(
                    path: APIConfig.Path.persons,
                    method: "POST",
                    body: person
                )
            },
            updatePerson: { person in
                try await request(
                    path: "\(APIConfig.Path.persons)/\(person.id)",
                    method: "PUT",
                    body: person
                )
            },
            deletePerson: { id in
                let _: EmptyResponse = try await request(
                    path: "\(APIConfig.Path.persons)/\(id)",
                    method: "DELETE"
                )
            },
            fetchTransactions: { date, type in
                // Query parameter 구성은 서버 API 스펙에 따라 조정
                try await request(path: APIConfig.Path.transactions)
            },
            createTransaction: { personID, transaction in
                try await request(
                    path: "\(APIConfig.Path.persons)/\(personID)/transactions",
                    method: "POST",
                    body: transaction
                )
            },
            updateTransaction: { transaction in
                try await request(
                    path: "\(APIConfig.Path.transactions)/\(transaction.id)",
                    method: "PUT",
                    body: transaction
                )
            },
            deleteTransaction: { id in
                let _: EmptyResponse = try await request(
                    path: "\(APIConfig.Path.transactions)/\(id)",
                    method: "DELETE"
                )
            }
        )
    }()
}

private struct EmptyResponse: Decodable {}
```

## 템플릿: Mock 구현 (서버 API 스펙 전달 전 사용)

```swift
// Core/Clients/DataClient+Mock.swift
import ComposableArchitecture
import Foundation

extension DataClient {
    /// 서버 API 스펙 전달 전까지 사용하는 Mock 구현.
    /// liveValue 대신 이 값을 DependencyKey에 등록하여 사용한다.
    static let mockValue: Self = {
        let storage = LockIsolated<[Person]>(Person.mockList)

        return Self(
            fetchPersons: {
                storage.value
            },
            fetchPerson: { id in
                guard let person = storage.value.first(where: { $0.id == id }) else {
                    throw APIError.unknown
                }
                return person
            },
            createPerson: { person in
                storage.withValue { $0.append(person) }
                return person
            },
            updatePerson: { person in
                storage.withValue { persons in
                    if let index = persons.firstIndex(where: { $0.id == person.id }) {
                        persons[index] = person
                    }
                }
                return person
            },
            deletePerson: { id in
                storage.withValue { $0.removeAll { $0.id == id } }
            },
            fetchTransactions: { date, type in
                let allTransactions = storage.value.flatMap(\.transactions)
                return allTransactions.filter { transaction in
                    let matchesDate = transaction.date.isSameMonth(as: date)
                    let matchesType = type.map { transaction.type == $0 } ?? true
                    return matchesDate && matchesType
                }
            },
            createTransaction: { personID, transaction in
                storage.withValue { persons in
                    if let index = persons.firstIndex(where: { $0.id == personID }) {
                        persons[index].transactions.append(transaction)
                    }
                }
                return transaction
            },
            updateTransaction: { transaction in
                storage.withValue { persons in
                    for i in persons.indices {
                        if let j = persons[i].transactions.firstIndex(where: { $0.id == transaction.id }) {
                            persons[i].transactions[j] = transaction
                        }
                    }
                }
                return transaction
            },
            deleteTransaction: { id in
                storage.withValue { persons in
                    for i in persons.indices {
                        persons[i].transactions.removeAll { $0.id == id }
                    }
                }
            }
        )
    }()
}
```

## 규칙

- API Client는 `@DependencyClient` 매크로로 정의한다
- 모든 endpoint closure는 `@Sendable`로 선언한다
- 에러 타입은 `APIError`로 통일한다
- JSON 디코딩은 `iso8601` date strategy 사용
- Authorization 헤더는 `KeychainClient`에서 토큰을 가져와 설정한다
- 서버 API 스펙 전달 전까지 `mockValue`로 개발을 진행한다
- `liveValue`는 서버 API 스펙이 확정된 후 구현한다

## 파일 위치

```
Dori-iOS/Core/Clients/
  APIError.swift
  APIConfig.swift
  DataClient.swift
  DataClient+Live.swift
  DataClient+Mock.swift
```
