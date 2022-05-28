//
//  APIFailure.swift
//

import Foundation

enum Failure: Error {
    case decodingError
    case urlConstructError
    case APIError(Error)
}
