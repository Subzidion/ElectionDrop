// @generated
// This file was automatically generated and can be edited to
// implement advanced custom scalar functionality.
//
// Any changes to this file will not be overwritten by future
// code generation execution.

import ApolloAPI

/// A signed eight-byte integer. The upper big integer values are greater than the
/// max value for a JavaScript number. Therefore all big integers will be output as
/// strings and not numbers.
public typealias BigInt = String
