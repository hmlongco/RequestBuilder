//
//  MainListView.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/30/22.
//

import SwiftUI

struct MainListView: View {

    let users: [User]

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(users) { user in
                    NavigationLink(destination: DetailsView(user: user)) {
                        HStack {
                            MainListCardView(user: user)
                                .accentColor(Color(UIColor.label))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .padding(16)
            .navigationTitle("RequestBuilder")
        }
        .background(Color(.systemGroupedBackground))
    }

}

struct MainListView2: View {

    let users: [User]

    var body: some View {
        List {
            ForEach(users) { user in
                NavigationLink(destination: DetailsView(user: user)) {
                    MainListCardView(user: user)
                }
            }
            .navigationTitle("RequestBuilder")
        }
    }

}

struct MainListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainListView(users: User.users)
        }
    }
}
