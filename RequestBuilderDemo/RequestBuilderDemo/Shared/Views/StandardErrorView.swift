//
//  StandardErrorView.swift
//  LiveFrontDemo
//
//  Created by Michael Long on 8/30/22.
//

import SwiftUI

struct StandardErrorView: View {

    let error: String
    var retry: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text(error)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.red)
                )

            if let retry = retry {
                Button("Try Again") {
                    retry()
                }
            }

            Spacer()
        }
        .padding()
    }

}

struct StandardErrorView_Previews: PreviewProvider {
    static var previews: some View {
        StandardErrorView(error: "This is an error message that must be seen. If you're not seeing it...")
    }
}
