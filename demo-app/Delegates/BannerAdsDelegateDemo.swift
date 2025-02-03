import Foundation
import XMediator

class BannerAdsDelegateDemo: BannerAdsDelegate {
    func didLoad(placementId: String, result: LoadResult) {
        Utils.logger.log("banner { placement_id: \(placementId) } loaded with network: \(result.success?.description ?? "")")
    }
    
    func didRecordImpression(placementId: String, data: ImpressionData) {
        Utils.logger.log("banner { placement_id: \(placementId) } recorded impression with revenue: \(data.revenue)")
    }
    
    func didClick(placementId: String) {
        Utils.logger.log("banner { placement_id: \(placementId) } was clicked")
    }
}
