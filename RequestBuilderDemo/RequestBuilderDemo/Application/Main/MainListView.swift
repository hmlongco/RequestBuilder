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
        GroupedScrollView {
            GroupedSectionView {
                ForEach(users) { user in
                    NavigationLink(destination: DetailsView(user: user)) {
                        GroupedDisclosureView {
                            MainListCardView(user: user)
                        }
                    }
                }
            }
            .navigationTitle("RequestBuilder")
        }
    }

}

// following is broken under iOS 16
// https://michaellong.medium.com/swiftui-lists-are-broken-and-cant-be-fixed-a7114d0baaba
struct BrokenMainListView: View {

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
