// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct UpdateData: ElectionsGQL.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment updateData on Update { __typename id jurisdictionType hash timestamp voteTalliesByUpdateId { __typename nodes { __typename id votes ballotResponseId votePercentage } } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: any ApolloAPI.ParentType { ElectionsGQL.Objects.Update }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", ElectionsGQL.BigInt.self),
    .field("jurisdictionType", String?.self),
    .field("hash", String?.self),
    .field("timestamp", ElectionsGQL.Datetime?.self),
    .field("voteTalliesByUpdateId", VoteTalliesByUpdateId.self),
  ] }

  public var id: ElectionsGQL.BigInt { __data["id"] }
  public var jurisdictionType: String? { __data["jurisdictionType"] }
  public var hash: String? { __data["hash"] }
  public var timestamp: ElectionsGQL.Datetime? { __data["timestamp"] }
  /// Reads and enables pagination through a set of `VoteTally`.
  public var voteTalliesByUpdateId: VoteTalliesByUpdateId { __data["voteTalliesByUpdateId"] }

  /// VoteTalliesByUpdateId
  ///
  /// Parent Type: `VoteTalliesConnection`
  public struct VoteTalliesByUpdateId: ElectionsGQL.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ElectionsGQL.Objects.VoteTalliesConnection }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("nodes", [Node?].self),
    ] }

    /// A list of `VoteTally` objects.
    public var nodes: [Node?] { __data["nodes"] }

    /// VoteTalliesByUpdateId.Node
    ///
    /// Parent Type: `VoteTally`
    public struct Node: ElectionsGQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { ElectionsGQL.Objects.VoteTally }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", ElectionsGQL.BigInt.self),
        .field("votes", ElectionsGQL.BigInt?.self),
        .field("ballotResponseId", ElectionsGQL.BigInt?.self),
        .field("votePercentage", ElectionsGQL.BigFloat?.self),
      ] }

      public var id: ElectionsGQL.BigInt { __data["id"] }
      public var votes: ElectionsGQL.BigInt? { __data["votes"] }
      public var ballotResponseId: ElectionsGQL.BigInt? { __data["ballotResponseId"] }
      public var votePercentage: ElectionsGQL.BigFloat? { __data["votePercentage"] }
    }
  }
}
