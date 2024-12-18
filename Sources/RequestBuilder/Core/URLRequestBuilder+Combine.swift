//
//  URLRequestBuilder+Combine.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/29/24.
//

import Foundation
import Combine

extension URLRequestBuilder {

    /// Combine data feed from session manager
    public func data() -> AnyPublisher<Data, Error> {
        Future { promise in
            Task {
                do {
                    let (data, _) = try await self.data()
                    if let data {
                        promise(.success(data))
                    } else {
                        throw URLError(.cannotDecodeContentData)
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// Combine raw data and response feed from session manager
    public func data() -> AnyPublisher<(Data?, HTTPURLResponse?), Error> {
        Future { promise in
            Task {
                do {
                    let (data, response) = try await self.data()
                    promise(.success((data, response)))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// Fetches requested data from the session manager and decodes it into the provided type.
    public func data<T:Decodable>(type: T.Type, decoder: DataDecoder? = nil) -> AnyPublisher<T, Error> {
        Future { promise in
            Task {
                do {
                    let data = try await self.data(type: type)
                    promise(.success(data))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
