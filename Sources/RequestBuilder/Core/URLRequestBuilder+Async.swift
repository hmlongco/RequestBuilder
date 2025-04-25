//
//  URLRequestBuilder+Async.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/29/24.
//

import Foundation

extension URLRequestBuilder {

    /// Data request call from session manager
    public func data() async throws -> Data {
        let (data, _) = try await manager.data(for: request)
        if let data {
            return data
        } else {
            throw URLError(.cannotDecodeContentData)
        }
    }

    /// Raw data and response request call from session manager
    public func data() async throws -> (Data?, HTTPURLResponse?) {
        try await manager.data(for: request)
    }

    /// Typed request call from session manager
    public func data<T:Decodable>(type: T.Type, decoder: DataDecoder? = nil) async throws -> T {
        let decoder = decoder ?? manager.decoder
        let (data, _) = try await manager.data(for: request)
        if let data {
            do {
                return try decoder.decode(type, from: data)
            } catch {
                throw error
            }
        } else {
            throw URLError(.cannotDecodeContentData)
        }
    }

}
