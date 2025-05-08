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
            StandardLoadingView()
                .padding(50)
                .task {
                    await viewModel.load()
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
    Container.shared.requestUsers.mock { User.mockUsers }
    NavigationStack { MainView() }
}
#Preview {
    Container.shared.requestUsers.mock { [] }
    MainView()
}
#Preview {
    Container.shared.requestUsers.mock { throw APIError.connection }
    MainView()
}
#endif
