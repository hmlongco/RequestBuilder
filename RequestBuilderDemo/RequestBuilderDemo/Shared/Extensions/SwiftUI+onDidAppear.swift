//
//  SwiftUI+onDidAppear.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 9/21/22.
//

import SwiftUI

extension View {
    func onDidAppear(_ perform: @escaping (() -> Void)) -> some View {
        self.modifier(ViewDidAppearModifier(callback: perform))
    }
}

struct ViewDidAppearModifier: ViewModifier {
    let callback: () -> Void
    func body(content: Content) -> some View {
        content
            .background(ViewDidAppearHandler(onDidAppear: callback))
    }
}

struct ViewDidAppearHandler: UIViewControllerRepresentable {
    func makeCoordinator() -> ViewDidAppearHandler.Coordinator {
        Coordinator(onDidAppear: onDidAppear)
    }

    let onDidAppear: () -> Void

    func makeUIViewController(context: UIViewControllerRepresentableContext<ViewDidAppearHandler>) -> UIViewController {
        context.coordinator
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ViewDidAppearHandler>) {
    }

    typealias UIViewControllerType = UIViewController

    class Coordinator: UIViewController {
        let onDidAppear: () -> Void

        init(onDidAppear: @escaping () -> Void) {
            self.onDidAppear = onDidAppear
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            onDidAppear()
        }
    }
}
