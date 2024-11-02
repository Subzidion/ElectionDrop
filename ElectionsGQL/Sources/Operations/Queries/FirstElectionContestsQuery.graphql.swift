// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class FirstElectionContestsQuery: GraphQLQuery {
  public static let operationName: String = "FirstElectionContests"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query FirstElectionContests { allElections(first: 1, orderBy: ELECTION_DATE_DESC) { __typename nodes { __typename name electionDate id updatesByElectionId { __typename nodes { __typename ...updateData } } contestsByElectionId { __typename nodes { __typename ...contestData } } } } }"#,
      fragments: [ContestData.self, UpdateData.self]
    ))

  public init() {}

  public struct Data: ElectionsGQL.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ElectionsGQL.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("allElections", AllElections?.self, arguments: [
        "first": 1,
        "orderBy": "ELECTION_DATE_DESC"
      ]),
    ] }

    /// Reads and enables pagination through a set of `Election`.
    public var allElections: AllElections? { __data["allElections"] }

    /// AllElections
    ///
    /// Parent Type: `ElectionsConnection`
    public struct AllElections: ElectionsGQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { ElectionsGQL.Objects.ElectionsConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("nodes", [Node?].self),
      ] }

      /// A list of `Election` objects.
      public var nodes: [Node?] { __data["nodes"] }

      /// AllElections.Node
      ///
      /// Parent Type: `Election`
      public struct Node: ElectionsGQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { ElectionsGQL.Objects.Election }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String?.self),
          .field("electionDate", ElectionsGQL.Datetime?.self),
          .field("id", String.self),
          .field("updatesByElectionId", UpdatesByElectionId.self),
          .field("contestsByElectionId", ContestsByElectionId.self),
        ] }

        public var name: String? { __data["name"] }
        public var electionDate: ElectionsGQL.Datetime? { __data["electionDate"] }
        public var id: String { __data["id"] }
        /// Reads and enables pagination through a set of `Update`.
        public var updatesByElectionId: UpdatesByElectionId { __data["updatesByElectionId"] }
        /// Reads and enables pagination through a set of `Contest`.
        public var contestsByElectionId: ContestsByElectionId { __data["contestsByElectionId"] }

        /// AllElections.Node.UpdatesByElectionId
        ///
        /// Parent Type: `UpdatesConnection`
        public struct UpdatesByElectionId: ElectionsGQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { ElectionsGQL.Objects.UpdatesConnection }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("nodes", [Node?].self),
          ] }

          /// A list of `Update` objects.
          public var nodes: [Node?] { __data["nodes"] }

          /// AllElections.Node.UpdatesByElectionId.Node
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

        /// AllElections.Node.ContestsByElectionId
        ///
        /// Parent Type: `ContestsConnection`
        public struct ContestsByElectionId: ElectionsGQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: any ApolloAPI.ParentType { ElectionsGQL.Objects.ContestsConnection }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("nodes", [Node?].self),
          ] }

          /// A list of `Contest` objects.
          public var nodes: [Node?] { __data["nodes"] }

          /// AllElections.Node.ContestsByElectionId.Node
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
  }
}
