import Foundation
import XMediator

struct PrintableLog {
    let timestamp: Date
    let message: String

    init(timestamp: Date = Date(), message: String) {
        self.timestamp = timestamp
        self.message = message
    }
}

struct AdInfo {
    let adType: AdType
    let placementId: String?
    var status: AdStatus
    var adSpace: String
    var logs: [PrintableLog]
}

enum AdStatus {
    case notReady
    case ready
}

@MainActor
final class AdsStore: ObservableObject {
    @Published private(set) var adsInfo: [AdType: AdInfo]

    init(mediator: Mediator = Settings.currentMediator) {
        adsInfo = Dictionary(uniqueKeysWithValues: AdType.allCases.map { adType in
            let placementId = Self.placementId(for: adType, mediator: mediator)
            return (adType, AdInfo(adType: adType,
                                   placementId: placementId,
                                   status: .notReady,
                                   adSpace: Self.defaultAdSpace(for: adType),
                                   logs: []))
        })
    }

    func update(mediator: Mediator) {
        for adType in AdType.allCases {
            guard let currentInfo = adsInfo[adType] else { continue }
            adsInfo[adType] = AdInfo(adType: adType,
                                     placementId: Self.placementId(for: adType, mediator: mediator),
                                     status: .notReady,
                                     adSpace: currentInfo.adSpace,
                                     logs: [])
        }
    }

    func recordLoaded(adType: AdType, placementId: String, network: String?) {
        guard var info = adsInfo[adType], info.placementId == placementId else { return }
        info.status = .ready
        let networkDescription = network ?? ""
        info.logs.append(PrintableLog(message: "'\(placementId)' loaded with network '\(networkDescription)'."))
        adsInfo[adType] = info
    }

    func record(adType: AdType, placementId: String, message: String) {
        guard var info = adsInfo[adType], info.placementId == placementId else { return }
        info.logs.append(PrintableLog(message: message))
        adsInfo[adType] = info
    }

    func setAdSpace(_ adSpace: String, for adType: AdType) {
        guard var info = adsInfo[adType] else { return }
        info.adSpace = adSpace
        adsInfo[adType] = info
    }

    func clearLogs(for adType: AdType) {
        guard var info = adsInfo[adType] else { return }
        info.logs.removeAll()
        adsInfo[adType] = info
    }

    func refreshReadiness() async {
        for adType in AdType.allCases {
            guard let info = adsInfo[adType], let placementId = info.placementId else { continue }
            let isReady: Bool
            switch adType {
            case .banner:
                isReady = XMediatorAds.banner.isReady(withPlacementId: placementId)
            case .interstitial:
                isReady = XMediatorAds.interstitial.isReady(withPlacementId: placementId)
            case .rewarded:
                isReady = XMediatorAds.rewarded.isReady(withPlacementId: placementId)
            case .appOpen:
                isReady = XMediatorAds.appOpen.isReady(withPlacementId: placementId)
            case .native:
                isReady = await XMediatorAds.native.isReady(withPlacementId: placementId)
            @unknown default:
                isReady = false
            }
            setStatus(isReady ? .ready : .notReady, for: adType, placementId: placementId)
        }
    }

    func setStatus(_ status: AdStatus, for adType: AdType, placementId: String) {
        guard var info = adsInfo[adType], info.placementId == placementId else { return }
        info.status = status
        adsInfo[adType] = info
    }

    private static func placementId(for adType: AdType, mediator: Mediator) -> String? {
        switch adType {
        case .banner:
            return mediator.bannerPlacementId
        case .interstitial:
            return mediator.interstitialPlacementId
        case .rewarded:
            return mediator.rewardedPlacementId
        case .appOpen:
            return mediator.appOpenPlacementId
        case .native:
            return Settings.nativeLayoutType == .standard ? mediator.nativeStandardPlacementId : mediator.nativeCompactPlacementId
        @unknown default:
            return nil
        }
    }

    private static func defaultAdSpace(for adType: AdType) -> String {
        switch adType {
        case .banner:
            return "banner_space"
        case .native:
            return "native_space"
        case .interstitial:
            return "interstitial_space"
        case .rewarded:
            return "rewarded_space"
        case .appOpen:
            return "appopen_space"
        @unknown default:
            return "ad_space"
        }
    }
}

extension AdType {
    var displayName: String {
        switch self {
        case .banner:
            return "Banner"
        case .interstitial:
            return "Interstitial"
        case .rewarded:
            return "Rewarded"
        case .appOpen:
            return "App Open"
        case .native:
            return "Native"
        @unknown default:
            return "Unknown"
        }
    }
}
