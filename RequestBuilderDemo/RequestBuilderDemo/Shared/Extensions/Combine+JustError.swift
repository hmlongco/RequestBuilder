//
//  Combine+Extensions.swift
//  LiveFrontDemo
//
//  Created by Michael Long on 9/1/22.
//

import Foundation
import Combine

public struct JustError<Output, Failure: Error>: Publisher {

    var data: Output? = nil
    var error: Failure? = nil

    public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        subscriber.receive(subscription: JustErrorSubscription<S>(target: subscriber, data: data, error: error))
    }

    class JustErrorSubscription<Target: Subscriber>: Subscription where Target.Input == Output, Target.Failure == Failure {
        var target: Target?
        let data: Target.Input?
        let error: Target.Failure?

        internal init(target: Target? = nil, data: Target.Input?, error: Target.Failure?) {
            self.target = target
            self.data = data
            self.error = error
        }

        func request(_ demand: Subscribers.Demand) {
            guard demand > 0 else {
                return
            }
            if let error = error {
                target?.receive(completion: .failure(error))
            } else {
                if let data = data {
                    _ = target?.receive(data)
                }
                target?.receive(completion: .finished)
            }
        }

        func cancel() {
            target = nil
        }
    }

}
