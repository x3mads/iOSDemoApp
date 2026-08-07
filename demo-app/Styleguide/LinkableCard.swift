import SwiftUI

struct LinkableCard<Icon: View, Destination: View>: View {
    let title: String
    let description: String
    let isEnabled: Bool
    let onDisabledTap: (() -> Void)?
    @ViewBuilder var icon: () -> Icon
    @ViewBuilder var destination: () -> Destination

    init(title: String,
         description: String,
         isEnabled: Bool = true,
         onDisabledTap: (() -> Void)? = nil,
         @ViewBuilder icon: @escaping () -> Icon,
         @ViewBuilder destination: @escaping () -> Destination) {
        self.title = title
        self.description = description
        self.isEnabled = isEnabled
        self.onDisabledTap = onDisabledTap
        self.icon = icon
        self.destination = destination
    }

    var body: some View {
        Group {
            if isEnabled {
                NavigationLink(destination: destination) {
                    content
                }
            } else {
                Button(action: { onDisabledTap?() }) {
                    content
                }
            }
        }
        .opacity(isEnabled ? 1 : 0.5)
    }

    private var content: some View {
        Card(innerPadding: .init(horizontal: Theme.Card.paddingHorizontal,
                                vertical: Theme.Card.paddingVertical)) {
            HStack(alignment: .center, spacing: Theme.Card.iconSpacing) {
                icon()
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .fontWeight(.semibold)
                        .foregroundColor(Colors.secondaryTitle)
                        .multilineTextAlignment(.leading)
                    Text(description)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(Colors.primaryTitle)
            }
        }
    }
}

struct LinkableSystemIcon: View {
    let iconSystemName: String

    var body: some View {
        Image(systemName: iconSystemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
            .foregroundColor(Colors.primaryTitle)
    }
}

extension LinkableCard where Icon == LinkableSystemIcon {
    init(iconSystemName: String,
         title: String,
         description: String,
         isEnabled: Bool = true,
         onDisabledTap: (() -> Void)? = nil,
         @ViewBuilder destination: @escaping () -> Destination) {
        self.init(title: title,
                  description: description,
                  isEnabled: isEnabled,
                  onDisabledTap: onDisabledTap,
                  icon: { LinkableSystemIcon(iconSystemName: iconSystemName) },
                  destination: destination)
    }
}
