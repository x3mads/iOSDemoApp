import SwiftUI

struct NotSetUpAdTypeCard: View {
    let info: AdInfo

    var body: some View {
        Card {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(info.adType.displayName)
                        .foregroundColor(Colors.secondaryTitle)
                        .fontWeight(.bold)
                }
                Spacer(minLength: 0)
                Text("Not set up")
                    .foregroundColor(Colors.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
