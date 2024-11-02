// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ContestsQuery: GraphQLQuery {
  public static let operationName: String = "Contests"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query Contests($electionId: String!) { allUpdates(condition: { electionId: $electionId }) { __typename nodes { __typename ...updateData } } allContests(condition: { electionId: $electionId }) { __typename nodes { __typename ...contestData } } }"#,
      fragments: [ContestData.self, UpdateData.self]
    ))

  public var electionId: String

  public init(electionId: String) {
    self.electionId = electionId
  }

  public var __variables: Variables? { ["electionId": electionId] }

  public struct Data: ElectionsGQL.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ElectionsGQL.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("allUpdates", AllUpdates?.self, arguments: ["condition": ["electionId": .variable("electionId")]]),
      .field("allContests", AllContests?.self, arguments: ["condition": ["electionId": .variable("electionId")]]),
    ] }

    /// Reads and enables pagination through a set of `Update`.
    public var allUpdates: AllUpdates? { __data["allUpdates"] }
    /// Reads and enables pagination through a set of `Contest`.
    public var allContests: AllContests? { __data["allContests"] }

    /// AllUpdates
    ///
    /// Parent Type: `UpdatesConnection`
    public struct AllUpdates: ElectionsGQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { ElectionsGQL.Objects.UpdatesConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("nodes", [Node?].self),
      ] }

      /// A list of `Update` objects.
      public var nodes: [Node?] { __data["nodes"] }

      /// AllUpdates.Node
      ///
      /// Parent Type: `Update`
      public struct Node: ElectionsGQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { ElectionsGQL.Objects.Update }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(UpdateData.self),
        ] }

        public var id: ElectionsGQL.BigInt { __data["id"] }
        public var jurisdictionType: String? { __data["jurisdictionType"] }
        public var hash: String? { __data["hash"] }
        public var timestamp: ElectionsGQL.Datetime? { __data["timestamp"] }
        /// Reads and enables pagination through a set of `VoteTally`.
        public var voteTalliesByUpdateId: VoteTalliesByUpdateId { __data["voteTalliesByUpdateId"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var updateData: UpdateData { _toFragment() }
        }

        public typealias VoteTalliesByUpdateId = UpdateData.VoteTalliesByUpdateId
      }
    }

    /// AllContests
    ///
    /// Parent Type: `ContestsConnection`
    public struct AllContests: ElectionsGQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { ElectionsGQL.Objects.ContestsConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("nodes", [Node?].self),
      ] }

      /// A list of `Contest` objects.
      public var nodes: [Node?] { __data["nodes"] }

      /// AllContests.Node
      ///
      /// Parent Type: `Contest`
      public struct Node: ElectionsGQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { ElectionsGQL.Objects.Contest }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ContestData.self),
        ] }

        public var ballotTitle: String? { __data["ballotTitle"] }
        public var contestKey: String? { __data["contestKey"] }
        public var district: String? { __data["district"] }
        public var jurisdictions: [String?]? { __data["jurisdictions"] }
        public var id: ElectionsGQL.BigInt { __data["id"] }
        /// Reads and enables pagination through a set of `BallotResponse`.
        public var ballotResponsesByContestId: BallotResponsesByContestId { __data["ballotResponsesByContestId"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var contestData: ContestData { _toFragment() }
        }

        public typealias BallotResponsesByContestId = ContestData.BallotResponsesByContestId
      }
    }
  }
}
