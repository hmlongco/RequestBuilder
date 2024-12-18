//
//  ContentView.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 9/6/22.
//

import SwiftUI
import Factory

struct ContentView: View {
    @State var presentAbout = false
    var body: some View {
        NavigationView {
            NavigationLink("Load Main View", destination: mainView)
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    var mainView: some View {
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
