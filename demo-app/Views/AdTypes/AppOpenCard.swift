import SwiftUI
import XMediator

struct AppOpenCard: View {
    @EnvironmentObject private var adsStore: AdsStore
    let info: AdInfo
    @State private var adSpace: String

    init(info: AdInfo) {
        self.info = info
        _adSpace = State(initialValue: info.adSpace)
    }

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: Theme.Card.maximalSpacing) {
                VStack(alignment: .leading, spacing: Theme.Card.minimalSpacing) {
                    header
                    adSpaceTextField
                }
                simulateButton

                NavigationLink {
                    AdTypeLogsView(adType: info.adType,
                                   logs: info.logs,
                                   onClear: { adsStore.clearLogs(for: info.adType) })
                } label: {
                    HStack {
                        Text("Logs")
                            .fontWeight(.semibold)
                            .foregroundColor(Colors.secondaryTitle)
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .foregroundColor(Colors.primaryTitle)
                    }
                }

                if let lastLog = info.logs.last {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lastLog.timestamp.formatted(date: .omitted, time: .standard))
                            .font(.system(size: 10))
                            .foregroundColor(Colors.secondaryText)
                        Text(lastLog.message)
                            .font(.system(size: 12))
                            .foregroundColor(Colors.text)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onChange(of: info.adSpace) { newValue in
            if adSpace != newValue {
                adSpace = newValue
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text(info.adType.displayName)
                    .foregroundColor(Colors.secondaryTitle)
                    .fontWeight(.bold)
                if let placementId = info.placementId {
                    Text(placementId)
                        .foregroundColor(Colors.secondaryTitle)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
            HStack(spacing: 5) {
                Text(info.status == .ready ? "Loaded" : "Not loaded yet")
                Image(systemName: info.status == .ready ? "checkmark.circle.fill" : "arrow.clockwise")
            }
            .foregroundColor(info.status == .ready ? Colors.loomitGreen : Colors.loomitLimeGreen)
        }
    }

    private var adSpaceTextField: some View {
        TextField("Ad Space", text: $adSpace)
            .foregroundColor(Colors.textFieldText)
            .textFieldStyle(.roundedBorder)
            .onSubmit {
                adsStore.setAdSpace(adSpace, for: .appOpen)
            }
    }

    private var simulateButton: some View {
        SecondaryButton("Simulate app opening", size: 14, maxWidth: true) {
            simulateAppOpen()
        }
    }

    private func simulateAppOpen() {
        guard let placementId = info.placementId,
              let viewController = Utils.getTopViewController() else { return }
        adsStore.setAdSpace(adSpace, for: .appOpen)
        let event = AdOpportunityEvent.appOpen(withAdSpace: adSpace)
        XMediatorAds.eventTracker.track(adOpportunity: event)
        adsStore.record(adType: info.adType, placementId: placementId, message: "Ad opportunity tracked")
        
        let isReady = XMediatorAds.appOpen.isReady(withPlacementId: placementId)
        adsStore.record(adType: info.adType, placementId: placementId, message: "isReady: \(isReady)")
        guard isReady else { return }
        
        let isCapped = XMediatorAds.appOpen.isAdSpaceCapped(adSpace)
        adsStore.record(adType: info.adType, placementId: placementId, message: "isCapped: \(isCapped)")
        guard !isCapped else { return }
        
        XMediatorAds.appOpen.present(withPlacementId: placementId,
                                     fromViewController: viewController,
                                     fromAdSpace: adSpace)
    }
}
