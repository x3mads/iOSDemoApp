import SwiftUI

struct TertiaryButton: View {
    let text: String
    let action: () -> Void

    init(_ text: String, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Colors.primaryTitle)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(Colors.tertiaryBackground)
                .overlay(Capsule().stroke(Colors.primaryTitle.opacity(0.6), lineWidth: 1))
                .clipShape(Capsule())
        }
    }
}
