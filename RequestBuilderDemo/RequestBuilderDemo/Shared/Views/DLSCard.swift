//
//  DLSCard.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/30/22.
//

import SwiftUI

struct DLSCard<Content:View>: View {

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(EdgeInsets(top: 16, leading: 8, bottom: 8, trailing: 8))
            .background(
                DLSCardShape()
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
            )
    }
}

struct DLSClippedCard<Content:View>: View {

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .clipShape(DLSCardShape())
            .background(
                DLSCardShape()
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
            )
    }
}

private struct DLSCardShape: Shape {

    func path(in rect: CGRect) -> Path {
        let largeRadius = CGFloat(16)
        let smallRadius = CGFloat(3)

        let minX = rect.origin.x
        let minY = rect.origin.y
        let maxX = minX + rect.size.width
        let maxY = minY + rect.size.height

        let path = UIBezierPath()
        path.lineCapStyle = .round
        // start
        path.move(to: CGPoint(x: minX + largeRadius, y: minY))
        // top line
        path.addLine(to: CGPoint(x: maxX - smallRadius, y: minY))
        // top right corner
        path.addArc(
            withCenter: CGPoint(x: maxX - smallRadius, y: minY + smallRadius),
            radius: smallRadius,
            startAngle: CGFloat(Double.pi * 3 / 2),
            endAngle: CGFloat(0),
            clockwise: true
        )
        // right side
        path.addLine(to: CGPoint(x: maxX, y: maxY - smallRadius))
        // bottom right corner
        path.addArc(
            withCenter: CGPoint(x: maxX - smallRadius, y: maxY - smallRadius),
            radius: smallRadius,
            startAngle: CGFloat(0),
            endAngle: CGFloat(Double.pi / 2),
            clockwise: true
        )
        // bottom line
        path.addLine(to: CGPoint(x: minX - smallRadius, y: maxY))
        // bottom left cornet
        path.addArc(
            withCenter: CGPoint(x: minX + smallRadius, y: maxY - smallRadius),
            radius: smallRadius,
            startAngle: CGFloat(Double.pi / 2),
            endAngle: CGFloat(Double.pi),
            clockwise: true
        )
        // left side
        path.addLine(to: CGPoint(x: minX, y: minY + largeRadius))
        // top-left corner
        path.addArc(
            withCenter: CGPoint(x: minX + largeRadius, y: minY + largeRadius),
            radius: largeRadius,
            startAngle: CGFloat(Double.pi),
            endAngle: CGFloat(Double.pi / 2 * 3),
            clockwise: true
        )
        path.close()

        return Path(path.cgPath)
    }
}

struct DLSCard_Previews: PreviewProvider {
    static var previews: some View {
        DLSClippedCard {
            HStack {
                Text("Hello!")
                Spacer()
            }
            .padding()
            .frame(minHeight: 150)
            .background(Color.green)
        }
    }
}
