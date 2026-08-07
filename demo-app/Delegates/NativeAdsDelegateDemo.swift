import Foundation
import XMediator

final class NativeAdsDelegateDemo: NativeAdsDelegate {
    private let store: AdsStore

    init(store: AdsStore) {
        self.store = store
    }

    func didLoad(placementId: String, result: LoadResult) {
        let network = result.success?.description ?? ""
        Utils.logger.log("native { placement_id: \(placementId) } loaded with network: \(network)")
        Task { @MainActor in
            store.recordLoaded(adType: .native, placementId: placementId, network: network)
        }
    }
    
    func didPresent(placementId: String) {
        Utils.logger.log("native { placement_id: \(placementId) } presented")
        record(placementId: placementId, message: "'\(placementId)' presented.")
    }
    
    func didRecordImpression(placementId: String, data: ImpressionData) {
        Utils.logger.log("native { placement_id: \(placementId) } recorded impression with revenue: \(data.revenue)")
        record(placementId: placementId, message: "'\(placementId)' recorded impression with revenue: '\(data.revenue)'.")
    }
    
    func didClick(placementId: String) {
        Utils.logger.log("native { placement_id: \(placementId) } was clicked")
        record(placementId: placementId, message: "'\(placementId)' was clicked.")
    }

    func failedToPresent(placementId: String, error: PresentError) {
        Utils.logger.error("native { placement_id: \(placementId) } failed to present, with error: \(error.localizedDescription)")
        record(placementId: placementId, message: "'\(placementId)' failed to present: \(error.localizedDescription).")
    }

    private func record(placementId: String, message: String) {
        Task { @MainActor in
            store.record(adType: .native, placementId: placementId, message: message)
        }
    }
}
