//
//  ContentView.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 9/6/22.
//

import SwiftUI
import FactoryKit

struct ContentView: View {
    @State var presentAbout = false
    var body: some View {
        NavigationStack {
            MainView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { presentAbout.toggle() } label: { Image(systemName: "globe") }
                    }
                }
                .sheet(isPresented: $presentAbout) {
                    AboutView(presentAbout: $presentAbout)
                }
        }
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
