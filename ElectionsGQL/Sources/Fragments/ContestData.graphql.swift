// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ContestData: ElectionsGQL.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment contestData on Contest { __typename ballotTitle contestKey district jurisdictions id ballotResponsesByContestId { __typename nodes { __typename name party id } } }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: any ApolloAPI.ParentType { ElectionsGQL.Objects.Contest }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("ballotTitle", String?.self),
    .field("contestKey", String?.self),
    .field("district", String?.self),
    .field("jurisdictions", [String?]?.self),
    .field("id", ElectionsGQL.BigInt.self),
    .field("ballotResponsesByContestId", BallotResponsesByContestId.self),
  ] }

  public var ballotTitle: String? { __data["ballotTitle"] }
  public var contestKey: String? { __data["contestKey"] }
  public var district: String? { __data["district"] }
  public var jurisdictions: [String?]? { __data["jurisdictions"] }
  public var id: ElectionsGQL.BigInt { __data["id"] }
  /// Reads and enables pagination through a set of `BallotResponse`.
  public var ballotResponsesByContestId: BallotResponsesByContestId { __data["ballotResponsesByContestId"] }

  /// BallotResponsesByContestId
  ///
  /// Parent Type: `BallotResponsesConnection`
  public struct BallotResponsesByContestId: ElectionsGQL.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ElectionsGQL.Objects.BallotResponsesConnection }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("nodes", [Node?].self),
    ] }

    /// A list of `BallotResponse` objects.
    public var nodes: [Node?] { __data["nodes"] }

    /// BallotResponsesByContestId.Node
    ///
    /// Parent Type: `BallotResponse`
    public struct Node: ElectionsGQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { ElectionsGQL.Objects.BallotResponse }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("name", String?.self),
        .field("party", String?.self),
        .field("id", ElectionsGQL.BigInt.self),
      ] }

      public var name: String? { __data["name"] }
      public var party: String? { __data["party"] }
      public var id: ElectionsGQL.BigInt { __data["id"] }
    }
  }
}
