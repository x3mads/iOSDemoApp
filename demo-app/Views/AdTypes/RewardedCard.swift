import SwiftUI
import XMediator

struct RewardedCard: View {
    @EnvironmentObject private var adsStore: AdsStore
    let info: AdInfo
    @State private var adSpace: String
    @State private var showConfirmation = false

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
        .alert("Rewarded opt-in", isPresented: $showConfirmation) {
            Button("See ad") {
                showRewardedAd()
            }
            Button("Opt-out", role: .cancel) { }
        } message: {
            Text("This already is an opportunity to show a rewarded ad, but you need to ask the user if he wants the reward or not first.\nFor example, if the user has just failed a level, you could provide more time to finish after seeing an ad.")
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
                adsStore.setAdSpace(adSpace, for: .rewarded)
            }
    }

    private var simulateButton: some View {
        VStack(alignment: .leading, spacing: 4) {
            SecondaryButton("Simulate opportunity", size: 14, maxWidth: true) {
                simulateOpportunity()
            }
            Text("(e.g., level failed)")
                .font(.system(size: 16))
                .foregroundColor(Colors.secondaryText)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func simulateOpportunity() {
        adsStore.setAdSpace(adSpace, for: .rewarded)
        let event = AdOpportunityEvent.rewarded(withAdSpace: adSpace)
        XMediatorAds.eventTracker.track(adOpportunity: event)
        if let placementId = info.placementId {
            adsStore.record(adType: info.adType, placementId: placementId, message: "Ad opportunity tracked")
        }
        showConfirmation = true
    }

    private func showRewardedAd() {
        guard let placementId = info.placementId,
              let viewController = Utils.getTopViewController() else { return }
        let isReady = XMediatorAds.rewarded.isReady(withPlacementId: placementId)
        adsStore.record(adType: info.adType, placementId: placementId, message: "isReady: \(isReady)")
        guard isReady else { return }
        let isCapped = XMediatorAds.rewarded.isAdSpaceCapped(adSpace)
        adsStore.record(adType: info.adType, placementId: placementId, message: "isCapped: \(isCapped)")
        guard !isCapped else { return }
        XMediatorAds.rewarded.present(withPlacementId: placementId,
                                      fromViewController: viewController,
                                      fromAdSpace: adSpace)
    }
}
