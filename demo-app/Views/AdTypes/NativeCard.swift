import SwiftUI
import XMediator

struct NativeCard: View {
    @EnvironmentObject private var adsStore: AdsStore
    let info: AdInfo
    @State private var adSpace: String
    @State private var isVisible = false

    init(info: AdInfo) {
        self.info = info
        _adSpace = State(initialValue: info.adSpace)
    }

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: Theme.Card.maximalSpacing) {
                VStack(alignment: .leading, spacing: Theme.Card.minimalSpacing) {
                    header
                    TextField("Ad Space", text: $adSpace)
                        .foregroundColor(Colors.textFieldText)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            adsStore.setAdSpace(adSpace, for: .native)
                        }
                }

                showButton

                if isVisible {
                    adContainer
                }

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

    private var showButton: some View {
        SecondaryButton(image: { Image(systemName: !isVisible ? "eye.fill" : "eye.slash.fill") },
                        text: !isVisible ? "Show" : "Hide",
                        size: 14, maxWidth: true) {
            showOrHide()
        }
    }

    private var adContainer: some View {
        NativeView(adSpace: adSpace)
            .frame(width: Settings.nativeLayoutType.size().width,
                   height: Settings.nativeLayoutType.size().height)
            .frame(maxWidth: .infinity)
            .background(Colors.tertiaryBackground)
    }

    private func showOrHide() {
        guard let placementId = info.placementId else { return }
        if isVisible {
            withAnimation { isVisible = false }
            return
        }
        adsStore.setAdSpace(adSpace, for: .native)
        Task { @MainActor in
            // Ad opportunity tracking is not exposed for native format in the current SDK
            let isReady = await XMediatorAds.native.isReady(withPlacementId: placementId)
            adsStore.record(adType: info.adType, placementId: placementId, message: "isReady: \(isReady)")
            guard isReady else { return }
            // Ad space capping is not exposed for native format in the current SDK
            withAnimation { isVisible = true }
        }
    }
}
