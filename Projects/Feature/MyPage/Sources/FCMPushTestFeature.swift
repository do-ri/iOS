//
//  FCMPushTestFeature.swift
//  Dori-iOS
//
//  Created by 강동영 on 3/27/26.
//

import ComposableArchitecture
import DoriDesignSystem
import DoriNetwork
import Foundation

@Reducer
public struct FCMPushTestFeature {
  @Dependency(\.fcmPushTestAPIClient) var fcmPushTestAPIClient
  @Dependency(\.continuousClock) var clock

  public init() {}

  private enum CancelID {
    case toastDismiss
  }

  @ObservableState
  public struct State: Equatable, Sendable {
    public var userId: Int64?
    public var title: String
    public var body: String
    public var isLoading: Bool
    public var toastItem: DoriToast?

    public var userIdDisplayText: String {
      userId.map { String($0) } ?? ""
    }

    public init(
      userId: Int64? = nil,
      title: String = "도리 푸시 Test",
      body: String = "테스트입니다.",
      isLoading: Bool = false,
      toastItem: DoriToast? = nil
    ) {
      self.userId = userId
      self.title = title
      self.body = body
      self.isLoading = isLoading
      self.toastItem = toastItem
    }
  }

  public enum Action: Equatable, Sendable {
    case onAppear
    case fetchUserIdResponse(Result<Int64, RequestError>)
    case titleChanged(String)
    case bodyChanged(String)
    case sendButtonTapped
    case sendResponse(Result<Bool, RequestError>)
    case toastDismissed
    case backButtonTapped
    case delegate(Delegate)

    public enum Delegate: Equatable, Sendable {
      case didTapBack
    }
  }

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .onAppear:
      state.isLoading = true
      let client = fcmPushTestAPIClient
      return .run { send in
        do {
          let userId = try await client.fetchUserId()
          await send(.fetchUserIdResponse(.success(userId)))
        } catch {
          await send(.fetchUserIdResponse(.failure(RequestError.from(error: error))))
        }
      }

    case .fetchUserIdResponse(.success(let userId)):
      state.isLoading = false
      state.userId = userId
      return .none

    case .fetchUserIdResponse(.failure(let error)):
      state.isLoading = false
      return showToast(&state, type: .error, message: error.message)

    case .titleChanged(let title):
      state.title = title
      return .none

    case .bodyChanged(let body):
      state.body = body
      return .none

    case .sendButtonTapped:
      guard let userId = state.userId, !state.isLoading else { return .none }
      state.isLoading = true
      let client = fcmPushTestAPIClient
      let title = state.title
      let body = state.body
      return .run { send in
        do {
          try await client.sendPushTest(userId, title, body)
          await send(.sendResponse(.success(true)))
        } catch {
          await send(.sendResponse(.failure(RequestError.from(error: error))))
        }
      }

    case .sendResponse(.success):
      state.isLoading = false
      return showToast(&state, type: .info, message: "푸시 전송 성공!")

    case .sendResponse(.failure(let error)):
      state.isLoading = false
      return showToast(&state, type: .error, message: error.message)

    case .toastDismissed:
      state.toastItem = nil
      return .cancel(id: CancelID.toastDismiss)

    case .backButtonTapped:
      return .send(.delegate(.didTapBack))

    case .delegate:
      return .none
    }
  }

  private func showToast(
    _ state: inout State,
    type: ToastType,
    message: String
  ) -> Effect<Action> {
    let toast = DoriToast(type: type, message: message)
    state.toastItem = toast

    let clock = self.clock
    return .run { send in
      try await clock.sleep(for: .seconds(toast.duration))
      await send(.toastDismissed)
    }
    .cancellable(id: CancelID.toastDismiss, cancelInFlight: true)
  }
}

@DependencyClient
public struct FCMPushTestAPIClient: Sendable {
  public var fetchUserId: @Sendable () async throws -> Int64
  public var sendPushTest: @Sendable (Int64, String, String) async throws -> Void
}

private enum FCMPushTestAPIClientError: LocalizedError {
  case unconfigured
  case invalidResponse
  case backendError(String)
  case noUserIdFound

  var errorDescription: String? {
    switch self {
    case .unconfigured:
      return "FCMPushTestAPIClient가 구성되지 않았습니다."
    case .invalidResponse:
      return "서버 응답이 올바르지 않습니다."
    case .backendError(let message):
      return message
    case .noUserIdFound:
      return "userId를 찾을 수 없습니다."
    }
  }
}

extension FCMPushTestAPIClient: DependencyKey {
  public static let liveValue = Self(
    fetchUserId: { throw FCMPushTestAPIClientError.unconfigured },
    sendPushTest: { _, _, _ in throw FCMPushTestAPIClientError.unconfigured }
  )
}

extension FCMPushTestAPIClient: TestDependencyKey {
  public static let previewValue = Self(
    fetchUserId: { 12345 },
    sendPushTest: { _, _, _ in }
  )

  public static let testValue = Self()
}

public extension FCMPushTestAPIClient {
  static func live(networkService: any NetworkService) -> Self {
    Self(
      fetchUserId: {
        let endpoint = FetchPartnersEndpoint(page: 0, size: 20)
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<[PartnerSummaryResponse]>.self
        )
        if let apiError = response.error {
          throw FCMPushTestAPIClientError.backendError(apiError.message ?? apiError.code)
        }
        guard response.success, let data = response.data else {
          throw FCMPushTestAPIClientError.invalidResponse
        }
        guard let userId = data.first?.recentDoriList.first?.userId else {
          throw FCMPushTestAPIClientError.noUserIdFound
        }
        return userId
      },
      sendPushTest: { userId, title, body in
        let endpoint = FCMPushTestEndpoint(userId: userId, title: title, body: body)
        let response = try await networkService.request(
          endpoint,
          responseType: SuccessResponse<EmptyResponse>.self
        )
        if let apiError = response.error {
          throw FCMPushTestAPIClientError.backendError(apiError.message ?? "푸시 전송에 실패했습니다.")
        }
        guard response.success else {
          throw FCMPushTestAPIClientError.invalidResponse
        }
      }
    )
  }
}

public extension DependencyValues {
  var fcmPushTestAPIClient: FCMPushTestAPIClient {
    get { self[FCMPushTestAPIClient.self] }
    set { self[FCMPushTestAPIClient.self] = newValue }
  }
}
