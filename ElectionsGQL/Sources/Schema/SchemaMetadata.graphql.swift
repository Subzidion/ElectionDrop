// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == ElectionsGQL.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == ElectionsGQL.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == ElectionsGQL.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == ElectionsGQL.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    switch typename {
    case "Query": return ElectionsGQL.Objects.Query
    case "BallotResponse": return ElectionsGQL.Objects.BallotResponse
    case "Contest": return ElectionsGQL.Objects.Contest
    case "Election": return ElectionsGQL.Objects.Election
    case "Update": return ElectionsGQL.Objects.Update
    case "VoteTally": return ElectionsGQL.Objects.VoteTally
    case "ElectionsConnection": return ElectionsGQL.Objects.ElectionsConnection
    case "UpdatesConnection": return ElectionsGQL.Objects.UpdatesConnection
    case "VoteTalliesConnection": return ElectionsGQL.Objects.VoteTalliesConnection
    case "ContestsConnection": return ElectionsGQL.Objects.ContestsConnection
    case "BallotResponsesConnection": return ElectionsGQL.Objects.BallotResponsesConnection
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
