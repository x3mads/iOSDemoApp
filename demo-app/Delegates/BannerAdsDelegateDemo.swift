import Foundation
import XMediator

final class BannerAdsDelegateDemo: BannerAdsDelegate {
    private let store: AdsStore

    init(store: AdsStore) {
        self.store = store
    }

    func didLoad(placementId: String, result: LoadResult) {
        let network = result.success?.description ?? ""
        Utils.logger.log("banner { placement_id: \(placementId) } loaded with network: \(network)")
        Task { @MainActor in
            store.recordLoaded(adType: .banner, placementId: placementId, network: network)
        }
    }
    
    func didRecordImpression(placementId: String, data: ImpressionData) {
        Utils.logger.log("banner { placement_id: \(placementId) } recorded impression with revenue: \(data.revenue)")
        record(placementId: placementId, message: "'\(placementId)' recorded impression with revenue: '\(data.revenue)'.")
    }
    
    func didClick(placementId: String) {
        Utils.logger.log("banner { placement_id: \(placementId) } was clicked")
        record(placementId: placementId, message: "'\(placementId)' was clicked.")
    }

    private func record(placementId: String, message: String) {
        Task { @MainActor in
            store.record(adType: .banner, placementId: placementId, message: message)
        }
    }
}
