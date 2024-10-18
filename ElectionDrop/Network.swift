//
//  Network.swift
//  ElectionDrop
//
//  Created by Daniel Heppner on 10/17/24.
//
import Apollo
import Foundation

class Network {
    static let shared = Network()
    private(set) lazy var apollo = ApolloClient(url: URL(string: "https://graphql.elections.danielhep.me/graphql")!)
}
