//
//  MainView.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/30/22.
//

import SwiftUI
import Factory

struct MainView: View {

    @StateObject var viewModel = MainViewModel()

    var body: some View {
        switch viewModel.state {

        case .loading:
            VStack(spacing: 50) {
                StandardLoadingView()
                    .onAppear {
//                        viewModel.combineLoad()
//                        viewModel.asyncLoadFromAppear()
                    }
                    .task(priority: .background) {
                         await viewModel.asyncLoadFromTask()
                    }
//                Button("Cancel") {
//                    // viewModel.cancellable?.cancel()
//                }
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
