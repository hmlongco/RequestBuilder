# RequestBuilder

A lightweight but powerful URLRequest Builder implementation for Combine.

### Session Manager

A Session Manager binds a base URL to a specific URLSession.

```swift
let base = URL(string: "https://randomuser.me/api")
let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
let sessionManager = BaseSessionManager(base: base, session: session)
```

Once you have a session manager, you can use it to build a request and fetch information from the associated host server.

### Request Builders

The Builder pattern makes it easy to build requests and then immediately proceed into decoding, processing, and then returning the desired data from the session's dataTaskPubliser.

```swift
public func list() -> AnyPublisher<[User], Error> {
    sessionManager.request()
        .add(path: "/")
        .add(queryItems: ["results" : "50", "seed": "998", "nat": "us"])
        .data(type: UserResultType.self, decoder: JSONDecoder())
        .map { $0.results }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}
```
The return type from `data(type:decoder:)` is a Combine `AnyPublisher<T, Error>`. And, as you can see, once you have a Combine publisher you can pretty much perform any operation you wish.

Need to just grab some raw data?
```swift
func image(for path: String) -> AnyPublisher<UIImage?, Never> {
    sessionManager.request(forURL: URL(string: path))
        .data()
        .map(UIImage.init)
        .replaceError(with: nil)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}
```
We've got you covered.

### Interceptors

Session Managers and Builders are pretty cool, but the entire concept really moves into overdrive once session manages are coupled with *Interceptors*.

Interceptors can be used to provide addition "default" data to all of the requests made to a given session, as shown below with the "Headers" interceptor.

```swift
let sessionManager = BaseSessionManager(base: base, session: session)
    .interceptor(URLRequestInterceptorHeaders([
        "User-Agent": "App(com.example; iOS 15.0.0) Swift 5.5",
        "APP_VERSION": "1.16.0",
        "APP_BUILD_NUM": "450",
        "OS": "iOS",
        "DEVICE_UUID": AppInfo.deviceID
    ]))
```

Interceptors can also be used to provide a standardized set of services for all requests made, like logging requests and responses to the terminal, or providing a default handler for mapping status codes. 

```swift
let sessionManager = BaseSessionManager(base: base, session: session)
    .interceptor(URLRequestInterceptorMock())
    .interceptor(URLRequestInterceptorLogging(mode: .debug))
    .interceptor(URLRequestInterceptorStatusCodes())
```

But one of the most powerful interceptors you can use is `URLRequestInterceptorMock`.

### Mocking

When `URLRequestInterceptorMock` is added to the mix, Mocking becomes a first-class citizen in RequestBuilder, and it's easy to intercept *any* URL request and replace the data normally returned by the API with mock data.
```swift
sessionManager.mocks?.mock(path: "/", data: UserResultType(results: []))

```
Execute the above mock code and now when our original `list()` service function is called it will receive a list containing empty data. You could also accomplish the same thing by passing in the raw JSON and use just let the regular decoding process do its work.
```swift
session.mocks?.mock(path: "/", json: "{ \"results\": [] }")
```
Need to mock some image data?
```swift
let image = UIImage(named: "User-JQ")?.pngData()
sessionManager.mocks?.mock(path: "/portraits/med/men/16.png", data: image)
```

Want to test your error handling? Try one of the following:
```swift
sessionManager.mocks?.mock(path: "/", error: MyError.connection)
sessionManager.mocks?.mock(path: "/", status: 401)
```
Want to reset everything back to normal?
```swift
sessionManager.mocks?.reset()
```
It's that simple.

With RequestBuilder, mocking happens at the bottom layer of the network stack. This makes it easy to do Unit Tests, Integration Tests, or even SwiftUI Previews without having to create extra protocols and inject mock services into your View Models.

This increases your code coverage by actually testing more of the code that will actually be used in the production application. 

### Installation

This is a BETA version of RequestBuilder. At this point in time it's only available as a Swift Package.

### License

Factory is available under the MIT license. See the LICENSE file for more info.

### Author

RequestBuilder was designed and written by Michael Long.

* LinkedIn: [https://www.linkedin.com/in/hmlong/](https://www.linkedin.com/in/hmlong/)
* Twitter: @hmlco

Michael was also one of Google's [Open Source Peer Reward](https://opensource.googleblog.com/2021/09/announcing-latest-open-source-peer-bonus-winners.html) winners in 2021 for his work on Resolver.
