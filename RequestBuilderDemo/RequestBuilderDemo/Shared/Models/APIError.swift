//
//  APIError.swift
//  Builder
//
//  Created by Michael Long on 1/18/21.
//

import Foundation
import Combine

public enum APIError: Error {
    case application
    case connection
    case security
    case server
    case validation(String)
    case unknown
}

extension APIError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .application:
            return "An unexpected data error occurred."
        case .connection:
            return "Unable to connect to server."
        default:
            return "An unexpected error occurred."
        }
    }
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        return self.description
    }
}

extension Publisher {
    public func mapAPIErrors() -> Publishers.MapError<Self, APIError> {
        self.mapError { error in
            if let error = error as? APIError {
                return error
            } else if let error = error as? URLError {
                switch error.code {
                case .appTransportSecurityRequiresSecureConnection:
                    return .security
                case .badServerResponse:
                    return .server
                case .networkConnectionLost, .notConnectedToInternet:
                    return .connection
                default:
                    return .unknown
                }
            } else if error is DecodingError {
                return .application
            } else {
                return .unknown
            }
        }
    }
}
