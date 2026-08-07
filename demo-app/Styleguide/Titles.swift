import SwiftUI

struct Title: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .fontWeight(.bold)
            .foregroundColor(Colors.primaryTitle)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 20)
    }
}

struct Subtitle: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .fontWeight(.bold)
            .foregroundColor(Colors.secondaryTitle)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
