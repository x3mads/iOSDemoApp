import SwiftUI

struct SimpleCard<Icon: View>: View {
    let title: String
    let description: String?
    @ViewBuilder var icon: () -> Icon
    var onPress: () -> Void

    @Environment(\.isEnabled) var isEnabled

    init(title: String,
         description: String? = nil,
         @ViewBuilder icon: @escaping () -> Icon,
         onPress: @escaping () -> Void) {
        self.title = title
        self.description = description
        self.icon = icon
        self.onPress = onPress
    }

    var body: some View {
        Button(action: onPress) {
            Card(innerPadding: .init(horizontal: Theme.Card.paddingHorizontal, vertical: Theme.Card.paddingVertical)) {
                HStack(alignment: .center, spacing: Theme.Card.iconSpacing) {
                    icon()
                    VStack(alignment: .leading, spacing: 5) {
                        Text(title).fontWeight(.semibold).foregroundColor(Colors.secondaryTitle).multilineTextAlignment(.leading)
                        if let description {
                            Text(description).multilineTextAlignment(.leading)
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .opacity(isEnabled ? 1 : 0.5)
            .frame(minHeight: 50)
        }
    }
}

extension SimpleCard where Icon == EmptyView {
    init(title: String,
         description: String? = nil,
         onPress: @escaping () -> Void) {
        self.init(title: title, description: description,
                  icon: { EmptyView() }, onPress: onPress)
    }
}
