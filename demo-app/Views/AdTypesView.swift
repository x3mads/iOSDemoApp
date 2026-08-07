import SwiftUI
import XMediator

struct AdTypesView: View {
    @EnvironmentObject private var adsStore: AdsStore

    private var adTypes: [AdInfo] {
        let allAdTypes = AdType.allCases
        return allAdTypes
            .compactMap { adsStore.adsInfo[$0] }
            .sorted { left, right in
                let leftIsConfigured = left.placementId != nil
                let rightIsConfigured = right.placementId != nil
                if leftIsConfigured != rightIsConfigured {
                    return leftIsConfigured && !rightIsConfigured
                }
                let leftIndex = allAdTypes.firstIndex(of: left.adType) ?? 0
                let rightIndex = allAdTypes.firstIndex(of: right.adType) ?? 0
                return leftIndex < rightIndex
            }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Card.minimalSpacing) {
                ForEach(adTypes, id: \.adType) { info in
                    if info.placementId == nil {
                        NotSetUpAdTypeCard(info: info)
                    } else {
                        switch info.adType {
                        case .banner:
                            BannerCard(info: info)
                        case .native:
                            NativeCard(info: info)
                        case .appOpen:
                            AppOpenCard(info: info)
                        case .interstitial:
                            InterstitialCard(info: info)
                        case .rewarded:
                            RewardedCard(info: info)
                        @unknown default:
                            NotSetUpAdTypeCard(info: info)
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.View.paddingHorizontal)
            .padding(.top, Theme.View.paddingTop)
            .padding(.bottom, Theme.View.paddingBottom)
        }
        .background(Colors.primaryBackground.ignoresSafeArea())
        .navigationTitle("Ad Types")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await adsStore.refreshReadiness()
        }
    }
}

struct AdTypeLogsView: View {
    let adType: AdType
    let logs: [PrintableLog]
    let onClear: () -> Void

    var body: some View {
        Group {
            if logs.isEmpty {
                Text("No events yet")
                    .foregroundColor(Colors.secondaryText)
                    .italic()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(Array(logs.reversed().enumerated()), id: \.offset) { _, log in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(log.timestamp.formatted(date: .omitted, time: .standard))
                                    .font(.system(size: 10))
                                    .foregroundColor(Colors.secondaryText)
                                Text(log.message)
                                    .font(.system(size: 12))
                                    .foregroundColor(Colors.text)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(Colors.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.horizontal, Theme.View.paddingHorizontal)
                    .padding(.top, Theme.View.paddingTop)
                }
            }
        }
        .background(Colors.primaryBackground.ignoresSafeArea())
        .navigationTitle("\(adType.displayName) Logs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onClear) {
                    Image(systemName: "trash")
                }
            }
        }
    }
}
