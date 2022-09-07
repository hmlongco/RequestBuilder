# RequestBuilder

A lightweight but powerful URLRequest Builder and SessionManager implementation for Combine.

### RequestBuilder

Builder pattern makes it easy to build and return Combine URLRequests.

```swift
    public func list() -> AnyPublisher<[User], Error> {
        sessionManager.request()
            .add(queryItems: ["results" : "50", "seed": "998", "nat": "us"])
            .data(type: UserResultType.self, decoder: JSONDecoder())
            .map { $0.results }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
```

### Session Manager

Session Manager provides a session "wrapped" by interceptors that can add information to requests and process the returned data.

```swift
    let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
    let sessionManager = BaseSessionManager(base: URL(string: "https://randomuser.me/api"), session: urlSession())
            .interceptor(URLRequestInterceptorMock())
            .interceptor(URLRequestInterceptorLogging(mode: .debug))
            .interceptor(URLRequestInterceptorStatusCodes())
            .interceptor(URLRequestInterceptorHeaders([
                "User-Agent": "App(com.example; iOS 15.0.0) Swift 5.5",
                "APP_VERSION": "1.16.0",
                "APP_BUILD_NUM": "450",
                "OS": "iOS",
                "DEVICE_UUID": "a604e727-e7c6-4634-94eb-5c562f14a5da"
            ]))
    }
```

