//
//  URLMockSessionManager.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/31/22.
//

import Foundation
import Combine

public final class MockSessionManager: URLSessionManager, @unchecked Sendable {

    public var base: URL?
    
    public lazy var encoder: DataEncoder = JSONEncoder()
    public lazy var decoder: DataDecoder = JSONDecoder()

    private var data: Data?
    private let error: Error?
    private let status: Int

    public init(data: Data?, status: Int = 200) {
        self.data = data
        self.error = nil
        self.status = status
    }

    public init<T: Encodable>(data: T, status: Int = 200) {
        self.data = nil
        self.error = nil
        self.status = status
        self.data = try? JSONEncoder().encode(data)
    }

    public init(error: Error) {
        self.data = nil
        self.error = error
        self.status = 999
    }

    public func request(forURL url: URL?) -> URLRequestBuilder {
        URLRequestBuilder(manager: self, url: url ?? URL(string: "/"))
    }

    public func data(for request: URLRequest) async throws -> (Data?, HTTPURLResponse?) {
        if let data = data {
            let url = request.url ?? URL(string: "/")!
            let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)
            return (data, response)
        }
        throw error ?? URLError(.badServerResponse)
    }

}
