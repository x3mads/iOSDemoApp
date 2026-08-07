import SwiftUI

struct Card<Content: View>: View {
    let innerPadding: EdgeInsets
    let outerPadding: EdgeInsets
    @ViewBuilder var content: () -> Content
    let foregroundColor: Color
    let backgroundColor: Color

    init(innerPadding: EdgeInsets = .init(horizontal: 10, vertical: 15),
         outerPadding: EdgeInsets = .zero,
         @ViewBuilder content: @escaping () -> Content) {
        self.innerPadding = innerPadding
        self.outerPadding = outerPadding
        self.content = content
        self.foregroundColor = Colors.text
        self.backgroundColor = Colors.secondaryBackground
    }

    fileprivate init(innerPadding: EdgeInsets = .init(horizontal: 10, vertical: 15),
                     outerPadding: EdgeInsets = .zero,
                     foregroundColor: Color,
                     backgroundColor: Color,
                     @ViewBuilder content: @escaping () -> Content) {
        self.innerPadding = innerPadding
        self.outerPadding = outerPadding
        self.content = content
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        content()
            .padding(.top, innerPadding.top)
            .padding(.bottom, innerPadding.bottom)
            .padding(.leading, innerPadding.leading)
            .padding(.trailing, innerPadding.trailing)
            .background(RoundedRectangle(cornerRadius: 10).fill(backgroundColor))
            .foregroundColor(foregroundColor)
            .padding(.top, outerPadding.top)
            .padding(.bottom, outerPadding.bottom)
            .padding(.leading, outerPadding.leading)
            .padding(.trailing, outerPadding.trailing)
    }
}

struct WarningCard<Content: View>: View {
    let innerPadding: EdgeInsets
    let outerPadding: EdgeInsets
    @ViewBuilder var content: () -> Content

    init(innerPadding: EdgeInsets = .init(horizontal: 10, vertical: 15),
         outerPadding: EdgeInsets = .zero,
         @ViewBuilder content: @escaping () -> Content) {
        self.innerPadding = innerPadding
        self.outerPadding = outerPadding
        self.content = content
    }

    var body: some View {
        Card(innerPadding: innerPadding, outerPadding: outerPadding,
             foregroundColor: Colors.loomitError, backgroundColor: Colors.errorBackground,
             content: content)
    }
}

struct CardDivider: View {
    var body: some View {
        Rectangle().frame(height: 1).foregroundColor(Colors.text.opacity(0.5))
    }
}
