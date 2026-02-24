import Foundation

public struct Person: Identifiable, Codable, Equatable, Sendable {
  public let id: UUID
  public var name: String

  public init(
    id: UUID = UUID(),
    name: String
  ) {
    self.id = id
    self.name = name
  }
}
