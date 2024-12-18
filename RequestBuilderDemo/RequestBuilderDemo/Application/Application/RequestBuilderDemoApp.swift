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
            ContentView2()
        }
    }
    
}

struct ContentView2: View {
    @State var string = ""
    @StateObject var vm = ViewModel()

    var body: some View {
        VStack {
            Button {
                Task {
                    print("F1: \(Thread.isMainThread)")
                    vm.fetch1()
                }

                Task {
                    print("F2: \(Thread.isMainThread)")
                    await vm.fetch2()
                }

                Task {
                    print("F3: \(Thread.isMainThread)")
                    await fetch()
                }
            } label: {
                Text ("Fetch")
            }

            Text(string)
            Text(vm.string)
        }
    }

    private func fetch() async {
        let url = URL(string: "https://google.com")!
        print("F3: \(Thread.isMainThread)")
        let data = try! await URLSession.shared.data(from: url)
        print("F3: \(Thread.isMainThread)")
        self.string = String(data: data.0, encoding: .utf8) ?? ""
    }
}

class ViewModel: ObservableObject {
    @Published var string = ""

    func fetch1() {
        let url = URL(string: "https://google.com")!
        print("F1: \(Thread.isMainThread)")
        let data = try! Data(contentsOf: url)
        print("F1: \(Thread.isMainThread)")
        string = String(data: data, encoding: .utf8) ?? ""
    }

    func fetch2() async {
        let url = URL(string: "https://google.com")!
        print("F2: \(Thread.isMainThread)")
        let data = try! await URLSession.shared.data(from: url)
        print("F2: \(Thread.isMainThread)")
        string = String(data: data.0, encoding: .utf8) ?? ""
    }
}


class SomeClass1 {
    var someClass2: SomeClass2!
    init(someClass2: SomeClass2) {
        self.someClass2 = someClass2
    }
}

class SomeClass2 {
    let someClass1: SomeClass1
    init(someClass1: SomeClass1) {
        self.someClass1 = someClass1
    }
}
