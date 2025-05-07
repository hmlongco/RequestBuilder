//
//  RequestBuilderDemoApp.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 9/6/22.
//

import SwiftUI
import Factory

@main
struct RequestBuilderDemoApp: App {

    init() {
        #if DEBUG
        setupMocks()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

}
