import Foundation
import XMediator

class NativeAdsDelegateDemo: NativeAdsDelegate {
    func didLoad(placementId: String, result: LoadResult) {
        Utils.logger.log("native { placement_id: \(placementId) } loaded with network: \(result.success?.description ?? "")")
    }
    
    func didPresent(placementId: String) {
        Utils.logger.log("native { placement_id: \(placementId) } presented")
    }
    
    func didRecordImpression(placementId: String, data: ImpressionData) {
        Utils.logger.log("native { placement_id: \(placementId) } recorded impression with revenue: \(data.revenue)")
    }
    
    func didClick(placementId: String) {
        Utils.logger.log("native { placement_id: \(placementId) } was clicked")
    }

    func failedToPresent(placementId: String, error: PresentError) {
        Utils.logger.error("native { placement_id: \(placementId) } failed to present, with error: \(error.localizedDescription)")
    }
}
