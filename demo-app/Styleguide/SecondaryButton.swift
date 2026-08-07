import SwiftUI

struct SecondaryButton<Content: View>: View {
    let isSelected: Bool
    @ViewBuilder var content: () -> Content
    var onPress: () -> Void

    @Environment(\.isEnabled) var isEnabled

    var body: some View {
        Button(action: onPress) {
            content()
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .foregroundColor(foregroundColor)
                .background(backgroundColor)
                .clipShape(Capsule())
        }
    }

    var foregroundColor: Color {
        let color = isSelected ? Color.black : Color.white
        return isEnabled ? color : color.opacity(0.5)
    }

    var backgroundColor: Color {
        let color = isSelected ? Color.white : Color.black
        return isEnabled ? color : color.opacity(0.5)
    }
}

extension SecondaryButton where Content == ButtonText {
    init(_ text: String,
         size: CGFloat = 18,
         weight: Font.Weight? = nil,
         maxWidth: Bool = false,
         maxHeight: Bool = false,
         isSelected: Bool = true,
         onPress: @escaping () -> Void = {}) {
        self.init(isSelected: isSelected, content: {
            ButtonText(text: text, size: size, weight: weight, maxWidth: maxWidth, maxHeight: maxHeight)
        }, onPress: onPress)
    }
}

extension SecondaryButton where Content == ButtonImageAndTextView {
    init(_ text: String,
         size: CGFloat = 18,
         weight: Font.Weight? = nil,
         maxWidth: Bool = false,
         maxHeight: Bool = false,
         isSelected: Bool = true,
         @ViewBuilder image: @escaping () -> Image,
         onPress: @escaping () -> Void = {}) {
        self.init(isSelected: isSelected, content: {
            ButtonImageAndTextView(imageFirst: false, maxWidth: maxWidth, maxHeight: maxHeight, text: {
                ButtonText(text: text, size: size, weight: weight, maxWidth: false, maxHeight: false)
            }, image: image)
        }, onPress: onPress)
    }

    init(@ViewBuilder image: @escaping () -> Image,
         text: String,
         size: CGFloat = 18,
         weight: Font.Weight? = nil,
         maxWidth: Bool = false,
         maxHeight: Bool = false,
         isSelected: Bool = true,
         onPress: @escaping () -> Void = {}) {
        self.init(isSelected: isSelected, content: {
            ButtonImageAndTextView(imageFirst: true, maxWidth: maxWidth, maxHeight: maxHeight, text: {
                ButtonText(text: text, size: size, weight: weight, maxWidth: false, maxHeight: false)
            }, image: image)
        }, onPress: onPress)
    }
}
