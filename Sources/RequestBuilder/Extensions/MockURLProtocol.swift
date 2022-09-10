//
//  MockURLProtocol.swift
//  Builder
//
//  Created by Michael Long on 9/30/21.
//

import Foundation

public class MockURLProtocol: URLProtocol {

    public enum MockProtocolError: Error {
        case failed
    }

    public static var shared: SharedMockURLProtocol = SharedMockURLProtocol()

    public override class func canInit(with request: URLRequest) -> Bool {
        return shared.handler(for: request.url) != nil
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    public override func startLoading() {
        if let delay = Self.shared.delay {
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + delay) {
                self.loadFromMockURLProtocol()
            }
        } else {
            loadFromMockURLProtocol()
        }
    }

    public override func stopLoading() {
        // nothing
    }

    private let lock = NSLock()

    private func loadFromMockURLProtocol() {
        defer { lock.unlock() }
        lock.lock()
        do {
            guard let handler = Self.shared.handler(for: request.url) else {
                throw MockProtocolError.failed
            }
            let result = try handler(request)
            if let response = result.1 {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = result.0 as? Data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
    }
}

public class SharedMockURLProtocol: URLMocking {

    public var responses: [String:MockURLResponse] = [:]
    public var enabled: Bool = true
    public var delay: Double?

    fileprivate func handler(for url: URL?) -> MockURLResponse? {
        guard let path = url?.absoluteString else {
            return nil
        }
        return enabled ? responses[path] : nil
    }

    public func add(path: String, response: @escaping MockURLResponse) {
        responses[path] = response
    }

    public func reset() {
        responses = [:]
    }

}

extension MockURLProtocol {
    
//    static func set(forPath path: String, response: @escaping (_ request: URLRequest) throws -> (Int,Data?)) {
//        defer { lock.unlock() }
//        lock.lock()
//        responses[path] = response
//    }
//    
//    static func set(forPath path: String, status: Int, data: Data? = nil) {
//        set(forPath: path) { _ in
//            (status, data)
//        }
//    }
//    
//    static func set(forPath path: String, error: APIError) {
//        set(forPath: path) { _ in
//            throw error
//        }
//    }
//    
//    static func set<T:Codable>(forPath path: String, status: Int, encode object: T) {
//        set(forPath: path) { _ in
//            guard let data = try? JSONEncoder().encode(object) else {
//                return (500, nil)
//            }
//            return (status, data)
//        }
//    }
//    
//    static func set(forPath path: String, status: Int, file: String) {
//        set(forPath: path) { _ in
//            guard let filePath = Bundle.main.url(forResource: file, withExtension: "json"), let data = try? Data(contentsOf: filePath) else {
//                return (404, nil)
//            }
//            return (status, data)
//        }
//    }
//    
//    static func set(forPath path: String, status: Int, json: String) {
//        set(forPath: path) { _ in
//            (status, json.data(using: .utf8))
//        }
//    }

}

extension MockURLProtocol {
    
//    static var username: String?
//    static var bundle: Bundle = Bundle.main
//
//    // maps request like GET /user/8922/ to get_user_8922.json and looks for a JSON file of that name in the bundle
//    // if username is set will first check for get_user_8922_username.json. allows different logins to influence mocks
//    static func setupDefaultJSONBundleHandler() {
//        Self.set(forPath: "*") { req in
//            guard let tempPath = req.url?.path.replacingOccurrences(of: "/", with: "_"), let method = req.httpMethod else {
//                return (500, nil)
//            }
//            let path = "\(method)\(tempPath)".trimmingCharacters(in: CharacterSet(["_"]))
//            if let user = Self.username,
//               let url = Self.bundle.url(forResource: "\(path)_\(user)".lowercased(), withExtension: "json"),
//               let data = try? Data(contentsOf: url) {
//                return (200, data)
//            }
//            if let url = Self.bundle.url(forResource: path.lowercased(), withExtension: "json"),
//               let data = try? Data(contentsOf: url) {
//                return (200, data)
//            }
//            return (404, nil)
//        }
//    }
}

extension URLSession {
    
    public static var mock: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }()
    
}
