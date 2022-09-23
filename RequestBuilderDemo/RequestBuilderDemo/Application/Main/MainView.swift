//
//  MainView.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/30/22.
//

import SwiftUI

struct MainView: View {

    @StateObject var viewModel = MainViewModel()

    var body: some View {
        switch viewModel.state {

        case .loading:
            StandardLoadingView()

                .onAppear {
                    viewModel.load() // demo for Combine load
//                    viewModel.asyncLoad() // demo for async await load
                }

        case .loaded(let users):
            MainListView(users: users)

        case .empty(let message):
            StandardEmptyView(message: message) {
                viewModel.refresh()
            }

        case .error(let message):
            StandardErrorView(error: message) {
                viewModel.refresh()
            }
        }
    }

}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
