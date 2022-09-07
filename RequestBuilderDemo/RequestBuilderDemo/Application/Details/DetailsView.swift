//
//  DetailsView.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/30/22.
//

import SwiftUI

struct DetailsView: View {

    let user: User

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                DetailsCardView(viewModel: DetailsViewModel(user: user))

                Text(disclaimer)
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(Color(.secondarySystemBackground).edgesIgnoringSafeArea(.vertical))
        .navigationTitle(user.fullname)
        .navigationBarTitleDisplayMode(.inline)
    }

    let disclaimer = "Information presented above is not repesentative of any person, living, dead, undead, or fictional."

}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailsView(user: User.mockJQ)
        }
    }
}
