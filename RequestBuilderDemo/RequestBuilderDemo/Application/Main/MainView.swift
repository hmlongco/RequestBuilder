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
                    .task {
                         await viewModel.asyncLoadFromTask()
                    }
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

#if DEBUG
#Preview {
    let _ = UserService.mockNetworkUsers()
    MainView()
}
#Preview {
    let _ = UserService.mockNetworkUsers(users: [])
    MainView()
}
#Preview {
    let _ = UserService.mockNetworkError()
    MainView()
}
#endif
