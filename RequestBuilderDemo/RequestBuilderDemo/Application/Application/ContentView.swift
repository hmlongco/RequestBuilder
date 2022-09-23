//
//  ContentView.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 9/6/22.
//

import SwiftUI

struct ContentView: View {
    @State var presentAbout = true
    var body: some View {
        NavigationView {
            MainView()
                .toolbar {
                    Button {
                        presentAbout.toggle()
                    } label: {
                        Image(systemName: "globe")
                    }
                }
                .sheet(isPresented: $presentAbout) {
                    AboutView(presentAbout: $presentAbout)
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
