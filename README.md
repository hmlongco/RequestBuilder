# URLRequestBuilder for Swift Async/Await & Combine

A lightweight but powerful URLSession/URLRequest Builder implementation. This version is derived from the original RxSwift request builder concept found in the [Builder](https://github.com/hmlongco/Builder) demo application and has been explicitly designed for use in modern SwiftUI applications.

The RequestBuilder library consists of three main components: the request builder itself; session managers; and request interceptors. 

RequestBuilder is also designed to make data *mocking* simple, easy, and painless. This is one of its most powerful features, and it can dramatically can change the way you write unit tests, integration tests, and SwiftUI Previews.

### Session Manager

Session Managers have a single purpose: To bind a base URL to a specific URLSession. They're defined by the `URLSessionManager` protocol, but in most cases you can just use the handy `BaseSessionManager` provided by RequestBuilder.

```swift
import RequestBuilder

let base = URL(string: "https://randomuser.me/api")
let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
let sessionManager = BaseSessionManager(base: base, session: session)
    .set(decoder: myCustomDecoder)
    .set(encoder: myCustomEncoder)) 
```
This example also shows how one can specify the default encoders and decoders used by the builder encoding and decoding functions. This comes in handy when, for example, all of the dates provided by a given API are in ISO8601 format and you don't want to specifiy it each and every time.

Once you've created and saved your session manager, you can then use it to build a request and fetch information from the associated host server.

### Request Builder

The Builder pattern makes it easy to build requests and then immediately proceed into decoding, processing, and then returning the desired data from the session's dataTaskPubliser.

Just add the required path to the base, add query parameters or form or JSON data for the body, then request the data. Here's a sample using Combine:

```swift
struct UserService {
    public func list() -> AnyPublisher<[User], Error> {
        sessionManager.request()
            .add(path: "/api")
            .add(queryItems: ["results" : "50", "seed": "998", "nat": "us"])
            .data(type: UserResultType.self)
            .map { $0.results }
            .eraseToAnyPublisher()
    }
}
```
The data function shown makes the request and then decodes the resulting data into a `UserResultType`. Now it's a piece of cake to map out the array of users, make sure we're on the main thread, and then return.

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

### Async/Await

If prefer async/await over Combine then don't worry, RequestBuilder has you covered there as well. 

Let's take a look at our original user list service function reimplemented for async/await.

```swift
struct UserService {
    public func list() async throws -> [User] {
        return try await session.request()
            .add(path: "/api")
            .add(queryItems: ["results" : "50", "seed": "998", "nat": "us"])
            .data(type: UserResultType.self)
            .map(\.results)
            .async()
    }
}
```
Other than the obvious change to the function signature, the builder structure is identical right up to the point where we have our mapped result. 

But instead of using `eraseToAnyPublisher()` to convert our result to `AnyPublisher`, we instead use the provided `async()` function to convert it to a throwing asynchronous call.

If you examine `MainViewModel` in the demo app you'll see two different examples of calling `UserService` using both Combine and Async/Await.

### Interceptors

Session Managers and Request Builders are pretty cool, but the entire concept really moves into overdrive once session managers are coupled with *Interceptors*.

Interceptors are thin wrappers around the session that manipulate the request and response data. They can, for example, be used to provide additional "default" data to all of the requests made to a given session.

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
Call `sessionManager.request()` and all of the above values will automatically be added to the request, ready and waiting.

Interceptors can also be used to provide a standardized set of services for all requests made, like automatically logging requests and responses to the terminal; providing a default handler for mapping status codes; or adding a mechanism to automatically retry every request. 

```swift
let sessionManager2 = BaseSessionManager(base: base, session: session)
    .interceptor(URLRequestInterceptorMock())
    .interceptor(URLRequestInterceptorLogging(mode: .debug))
    .interceptor(URLRequestInterceptorStatusCodes())
    .interceptor(URLRequestInterceptorRetry(1))
```

But one of the most powerful interceptors you can use is the very first one shown on the list, `URLRequestInterceptorMock`.

### Mocking

When `URLRequestInterceptorMock` is added to the mix, Mocking becomes a first-class citizen in RequestBuilder. It's easy to intercept *any* URL request and replace the data normally returned by the API with mock data.

Remember our original `list()` service function from above? Just add the following mock to the list and the next time it's called you'll receive a list containing empty data. 
```swift
sessionManager.mock {
    $0.add(path: "/api", data: UserResultType(results: []))
}
```
You could also accomplish the same thing by passing in the raw JSON and just let the regular decoding process do its work.
```swift
sessionManager.mock {
    $0.add(path: "/api", json: "{ \"results\": [] }")
}
```
Need to mock some image data?
```swift
sessionManager.mock {
    let image = UIImage(named: "User-JQ")?.pngData()
    $0.add(path: "/api/portraits/med/men/16.png", data: image)
}
```

Want to test your view model's error handling? Try one of the following:
```swift
sessionManager.mock {
    $0.add(path: "/api", error: MyError.connection)
    $0.add(path: "/api?results=50&seed=998&nat=us", status: 401)
}
```
Note the last case illustrates that you can also add url parameters to the path to ensure that you return the right mock for the right query. Order of the parameters doesn't matter, but if you add them you have to include all of them. For example,`?a=1` doesn't' match when the URL actually contains `?a=1&b=2`.

Want to do some sort of conditional logic on the request when it occurs? Or get the data from elsewhere?
```swift
sessionManager.mock {
    $0.add(path: "/api") { request in
        if let path = request.url?.absoluteString, path.contains("bad") {
            throw APIError.bad
        } else if let file = Bundle.main.url(forResource: "data", withExtension: "json") {
            return (try? Data(contentsOf: file), nil)
        } else {
            throw APIError.unknown
        }
    }
}
```

Finally, want to reset everything back to normal?
```swift
sessionManager.mocks?.reset()
```
It's that simple.

With RequestBuilder, mocking happens at the bottom layer of the network stack. This makes it easy to do unit tests, integration tests, or even SwiftUI Previews without having to create extra protocols and inject mock services into your View Models.

This can dramtically increase your code coverage by letting you test more of the code that will actually be used in the production application. 

### Encodable

The mocking layer has one other trick up its sleeve. Take another look at the first example shown.
```swift
sessionManager.mock {
    $0.add(path: "/api", data: UserResultType(results: []))
}
```
What's not obvious from this example is that while `UserResultType` is Decodable... it's not *Encodable*.  Confused? Let me explain.

The type must be Decodable in order to be processed and extracted from the response data. That's obvious. But if you look at the actual `User` type you'll see that it and its subtypes use all sorts of weird custom CodingKeys that were a pain to implement but are required just to read the data. 
 
 But it would be even more of a pain to also write all of the *encoders* needed. Esepcially since the only reason we'd be doing so would be in order to mock the actual data type. 
 
 So RequestBuilder has a feature built in that lets you supply the raw type in the mock and then have that type recognized and returned when you call `data(type:)`.
 
 Note that you have to call RequestBuilder's `data(type:)` for this to work. You can't call `data()` and then attempt to do your decoding yourself.

### Interceptor Configuration

And finally, RequestBuilder also allows for easy reconfiguration of any interceptor deep within the chain. Just provide the type you want to mutate. Consider.
```swift
sessionManager.configure(URLRequestInterceptorHeaders.self) {
    $0.add(token, forHeader: "Authorization")
}
```
Now every API call made through that session includes the authorization token.

Note that this is how `sessionManager.mock {}` is implemented. It's just a convenient shortcut for `sessionManager.configure(URLRequestInterceptorMock.self) {}`.

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
