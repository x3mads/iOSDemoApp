import SwiftUI

struct PrimaryButtonStyle {
    static let background = Color(hex: "75FBBB")
    static let content = Color.black
}

struct PrimaryButton<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var onPress: () -> Void

    @Environment(\.isEnabled) var isEnabled

    var body: some View {
        Button(action: onPress) {
            content()
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .foregroundColor(PrimaryButtonStyle.content)
                .background(PrimaryButtonStyle.background)
                .clipShape(Capsule())
                .opacity(isEnabled ? 1 : 0.5)
        }
    }
}

struct ButtonText: View {
    let text: String
    let size: CGFloat
    let weight: Font.Weight?
    let maxWidth: Bool
    let maxHeight: Bool

    var body: some View {
        Text(text)
            .font(.system(size: size))
            .fontWeight(weight)
            .frame(if: maxWidth, maxWidth: .infinity)
    }
}

extension PrimaryButton where Content == ButtonText {
    init(_ text: String,
         size: CGFloat = 18,
         weight: Font.Weight? = nil,
         maxWidth: Bool = false,
         maxHeight: Bool = false,
         onPress: @escaping () -> Void = {}) {
        self.init(content: {
            ButtonText(text: text,
                       size: size,
                       weight: weight,
                       maxWidth: maxWidth,
                       maxHeight: maxHeight)
        }, onPress: onPress)
    }
}

struct ButtonImageAndTextView: View {
    var imageFirst: Bool
    var maxWidth: Bool
    var maxHeight: Bool
    @ViewBuilder var text: () -> ButtonText
    @ViewBuilder var image: () -> Image

    var body: some View {
        HStack(spacing: 8) {
            if imageFirst {
                image()
                text()
            } else {
                text()
                image()
            }
        }.frame(if: maxWidth || maxHeight,
                maxWidth: maxWidth ? .infinity : nil,
                maxHeight: maxHeight ? .infinity : nil)
    }
}

extension PrimaryButton where Content == ButtonImageAndTextView {
    init(_ text: String,
         size: CGFloat = 18,
         weight: Font.Weight? = nil,
         maxWidth: Bool = false,
         maxHeight: Bool = false,
         @ViewBuilder image: @escaping () -> Image,
         onPress: @escaping () -> Void = {}) {
        self.init(content: {
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
         onPress: @escaping () -> Void = {}) {
        self.init(content: {
            ButtonImageAndTextView(imageFirst: true, maxWidth: maxWidth, maxHeight: maxHeight, text: {
                ButtonText(text: text, size: size, weight: weight, maxWidth: false, maxHeight: false)
            }, image: image)
        }, onPress: onPress)
    }
}
