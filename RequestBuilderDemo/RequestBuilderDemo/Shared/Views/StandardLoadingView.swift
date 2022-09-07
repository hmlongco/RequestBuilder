//
//  StandardLoadingView.swift
//  LiveFrontDemo
//
//  Created by Michael Long on 8/30/22.
//

import SwiftUI

struct StandardLoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
            Spacer()
        }
        .padding()
    }
}

struct StandardLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        StandardLoadingView()
    }
}
