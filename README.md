# RequestBuilder for Combine

A lightweight but powerful URLSession/URLRequest Builder implementation. This version is derived from the original RxSwift request builder cencept found in the [Builder](https://github.com/hmlongco/Builder) demo application and has been explicitly designed for use in modern SwiftUI applications.

The RequestBuilder library consists of three main components: session managers, request builders, and request interceptors. It's also designed to make data *mocking* simple, easy, and painless.

### Session Manager

Session Managers have a single purpose: To bind a base URL to a specific URLSession. They're defined by the `URLSessionManager` protocol, but in most cases you can just use the handy `BaseSessionManager` provided by RequestBuilder.

```swift
let base = URL(string: "https://randomuser.me/api")
let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
let sessionManager = BaseSessionManager(base: base, session: session)
```
Session managers also let you define the default encoders and decoders used by the builder functions.
```swift
let sessionManager = BaseSessionManager(base: base, session: session)
    .set(defaultDecoder: myCustomDecoder)
    .set(defaultEncoder: myCustomEncoder))
```
Once you have a session manager, you can use it to build a request and fetch information from the associated host server.

### Request Builders

The Builder pattern makes it easy to build requests and then immediately proceed into decoding, processing, and then returning the desired data from the session's dataTaskPubliser.

Just add the required path to the base, add query parameters or form or JSON data for the body, then request the data. Here's a sample:

```swift
struct UserService {
    public func list() -> AnyPublisher<[User], Error> {
        sessionManager.request()
            .add(path: "/")
            .add(queryItems: ["results" : "50", "seed": "998", "nat": "us"])
            .data(type: UserResultType.self)
            .map { $0.results }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
```
This particular generic data function decodes our data into a `UserResultType`. Now it's a piece of cake to map out the array of users, make sure we're on the main thread, and then return.

### Data

Just need to grab the raw data? Or use a bespoke URL?
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

Session Managers and Builders are pretty cool, but the entire concept really moves into overdrive once session managers are coupled with *Interceptors*.

Interceptors are thin wrappers around the session that manipulate the request and response data. They can, for example, be used to provide additional "default" data to all of the requests made to a given session, as shown below with the "Headers" interceptor.

```swift
let sessionManager1 = BaseSessionManager(base: base, session: session)
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
let sessionManager2 = BaseSessionManager(base: base, session: session)
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
Add the above mock to the list and the next time our original user `list()` service function is called it will receive a list containing empty data. You could also accomplish the same thing by passing in the raw JSON and use just let the regular decoding process do its work.
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

With RequestBuilder, mocking happens at the bottom layer of the network stack. This makes it easy to do unit tests, integration tests, or even SwiftUI Previews without having to create extra protocols and inject mock services into your View Models.

This can dramtically increase your code coverage by actually testing more of the code that will actually be used in the production application. 

### Installation

This is a **BETA** version of RequestBuilder. Most of the bits and pieces are nailed down and a lot of the rough edges have been filed off, but I make no guarantees that I won't see a better way to accomplish something and start moving things around.

As such, RequestBuilder is currently only available as a Swift Package.

### License

RequestBuilder is available under the MIT license. See the LICENSE file for more info.

### Author

RequestBuilder was designed and written by Michael Long.

* LinkedIn: [https://www.linkedin.com/in/hmlong/](https://www.linkedin.com/in/hmlong/)
* Twitter: @hmlco

Michael was also one of Google's [Open Source Peer Reward](https://opensource.googleblog.com/2021/09/announcing-latest-open-source-peer-bonus-winners.html) winners in 2021 for his work on Resolver.
