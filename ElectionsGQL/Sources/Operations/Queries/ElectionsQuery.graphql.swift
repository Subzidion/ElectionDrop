// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ElectionsQuery: GraphQLQuery {
  public static let operationName: String = "Elections"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query Elections { allElections { __typename nodes { __typename name electionDate id } } }"#
    ))

  public init() {}

  public struct Data: ElectionsGQL.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { ElectionsGQL.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("allElections", AllElections?.self),
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
        ] }

        public var name: String? { __data["name"] }
        public var electionDate: ElectionsGQL.Datetime? { __data["electionDate"] }
        public var id: String { __data["id"] }
      }
    }
  }
}
