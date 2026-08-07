import Foundation
import XMediator

final class InterstitialAdsDelegateDemo: InterstitialAdsDelegate {
    private let store: AdsStore

    init(store: AdsStore) {
        self.store = store
    }

    func didLoad(placementId: String, result: LoadResult) {
        let network = result.success?.description ?? ""
        Utils.logger.log("interstitial { placement_id: \(placementId) } loaded with network: \(network)")
        Task { @MainActor in
            store.recordLoaded(adType: .interstitial, placementId: placementId, network: network)
        }
    }

    func didPresent(placementId: String) {
        Utils.logger.log("interstitial { placement_id: \(placementId) } presented")
        record(placementId: placementId, message: "'\(placementId)' presented.")
    }
    
    func failedToPresent(placementId: String, error: PresentError) {
        Utils.logger.error("interstitial { placement_id: \(placementId) } failed to present, with error: \(error.localizedDescription)")
        record(placementId: placementId, message: "'\(placementId)' failed to present: \(error.localizedDescription).")
    }
    
    func didRecordImpression(placementId: String, data: ImpressionData) {
        Utils.logger.log("interstitial { placement_id: \(placementId) } recorded impression with revenue: \(data.revenue)")
        record(placementId: placementId, message: "'\(placementId)' recorded impression with revenue: '\(data.revenue)'.")
    }
    
    func willDismiss(placementId: String) {
        Utils.logger.log("interstitial { placement_id: \(placementId) } will be dismissed")
        record(placementId: placementId, message: "'\(placementId)' will be dismissed.")
    }
    
    func didDismiss(placementId: String) {
        Utils.logger.log("interstitial { placement_id: \(placementId) } was dismissed")
        record(placementId: placementId, message: "'\(placementId)' was dismissed.")
    }
    
    func didClick(placementId: String) {
        Utils.logger.log("interstitial { placement_id: \(placementId) } was clicked")
        record(placementId: placementId, message: "'\(placementId)' was clicked.")
    }

    private func record(placementId: String, message: String) {
        Task { @MainActor in
            store.record(adType: .interstitial, placementId: placementId, message: message)
        }
    }
}
