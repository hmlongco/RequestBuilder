//
//  DetailsCardView.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/30/22.
//

import SwiftUI
import Combine

struct DetailsCardView: View {

    @StateObject var viewModel: DetailsViewModel

    var body: some View {
        DLSClippedCard {
            VStack(spacing: 0) {
                DetailsPhotoView(photo: viewModel.photo(), name: viewModel.fullname)

                VStack(spacing: 12) {
                    VStack(spacing: 4) {
                        NameValueView(name: "Address", value: viewModel.street)
                        if viewModel.showCityStateZip {
                            NameValueView(name: "", value: viewModel.cityStateZip)
                        }
                    }

                    if viewModel.showContactBlock  {
                        VStack(spacing: 4) {
                            NameValueView(name: "Email", value: viewModel.email)
                            NameValueView(name: "Phone", value: viewModel.phone)
                        }
                    }

                    if viewModel.showAgeBlock  {
                        NameValueView(name: "Age", value: viewModel.age)
                    }
                }
                .padding()
            }
        }
    }

}

private struct NameValueView: View {

    let name: String
    let value: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(name)
                .font(.callout)
                .foregroundColor(.secondary)
            Spacer()
            if let value = value {
                Text(value)
            }
        }
    }
}

struct DetailsCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DetailsCardView(viewModel: DetailsViewModel(user: User.mockJQ))
            Spacer()
        }
    }
}
