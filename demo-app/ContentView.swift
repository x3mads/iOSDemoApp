import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @State private var settingsPresented = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Card.minimalSpacing) {
                    SdkStatusCard()
                    ManageAdTypesCard()
                    LinkableCard(iconSystemName: "lock.fill",
                                 title: "Privacy & Consent",
                                 description: "Manage GDPR/CCPA consent with CMP") {
                        PrivacyAndConsentView()
                    }
                    LinkableCard(iconSystemName: "person.fill",
                                 title: "User Properties",
                                 description: "Set user targeting and analytics data") {
                        UserPropertiesView()
                    }
                    LinkableCard(iconSystemName: "text.document",
                                 title: "Event Tracker",
                                 description: "Track purchases and app events") {
                        EventTrackerView()
                    }
                }
                .padding(.horizontal, Theme.View.paddingHorizontal)
                .padding(.top, Theme.View.paddingTop)
                .padding(.bottom, Theme.View.paddingBottom)
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
            .background(Colors.primaryBackground.ignoresSafeArea())
            .navigationTitle("XMediator iOS Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        settingsPresented = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.openDebuggingSuite()
                    } label: {
                        Image(systemName: "ladybug.fill")
                    }
                    .disabled(viewModel.initStatus != .initialized)
                }
            }
            .navigationDestination(isPresented: $settingsPresented) {
                SettingsView()
            }
        }
    }
}

struct SdkStatusCard: View {
    @EnvironmentObject private var viewModel: ContentViewModel

    private var statusText: String {
        switch viewModel.initStatus {
        case .idle: return "Not initialized"
        case .initializing: return "Initializing..."
        case .initialized: return "Initialized"
        }
    }

    private var statusColor: Color {
        viewModel.initStatus == .initialized ? Colors.loomitGreen : Colors.loomitLimeGreen
    }

    var body: some View {
        Card(innerPadding: .init(horizontal: 20, vertical: 15)) {
            VStack(alignment: .leading, spacing: Theme.Card.minimalSpacing) {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.initStatus == .initialized ? "checkmark.circle.fill" : "info.circle")
                        .foregroundColor(statusColor)
                    Text("SDK Status")
                        .fontWeight(.bold)
                        .foregroundColor(Colors.secondaryTitle)
                }
                Text(statusText)
                    .foregroundColor(statusColor)
                    .fontWeight(.medium)
                Text("App Key: \(viewModel.mediator.appKey)")
                    .font(.system(size: 12))
                    .foregroundColor(Colors.loomitOnSurfaceVariant)
                if viewModel.initStatus == .idle {
                    PrimaryButton("Initialize SDK", maxWidth: true) {
                        viewModel.start()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ManageAdTypesCard: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @State private var tooltipMessage: String?

    private var isEnabled: Bool { viewModel.initStatus == .initialized }

    var body: some View {
        LinkableCard(iconSystemName: "play.fill",
                     title: "Manage Ad Types",
                     description: "Show and check readiness for all ad formats",
                     isEnabled: isEnabled,
                     onDisabledTap: showInitTooltip) {
            AdTypesView()
        }
        .overlay(alignment: .top) {
            if let tooltipMessage {
                Text(tooltipMessage)
                    .font(.caption)
                    .foregroundColor(Colors.secondaryTitle)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Colors.tertiaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .offset(y: -8)
            }
        }
    }

    private func showInitTooltip() {
        tooltipMessage = "Initialize the SDK first."
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            tooltipMessage = nil
        }
    }
}

#Preview {
    let store = AdsStore()
    ContentView()
        .environmentObject(ContentViewModel(adsStore: store))
        .environmentObject(store)
}
