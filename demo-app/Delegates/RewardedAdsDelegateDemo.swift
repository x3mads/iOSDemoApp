import Foundation
import XMediator

class RewardedAdsDelegateDemo: RewardedAdsDelegate {
    func didLoad(placementId: String, result: LoadResult) {
        Utils.logger.log("rewarded { placement_id: \(placementId) } loaded with network: \(result.success?.description ?? "")")
    }

    func didPresent(placementId: String) {
        Utils.logger.log("rewarded { placement_id: \(placementId) } presented")
    }
    
    func failedToPresent(placementId: String, error: PresentError) {
        Utils.logger.error("rewarded { placement_id: \(placementId) } failed to present, with error: \(error.localizedDescription)")
    }
    
    func didRecordImpression(placementId: String, data: ImpressionData) {
        Utils.logger.log("rewarded { placement_id: \(placementId) } recorded impression with revenue: \(data.revenue)")
    }
    
    func willDismiss(placementId: String) {
        Utils.logger.log("rewarded { placement_id: \(placementId) } will be dismissed")
    }
    
    func didDismiss(placementId: String) {
        Utils.logger.log("rewarded { placement_id: \(placementId) } was dismissed")
    }
    
    func didClick(placementId: String) {
        Utils.logger.log("rewarded { placement_id: \(placementId) } was clicked")
    }
    
    func didEarnReward(placementId: String) {
        Utils.logger.log("rewarded { placement_id: \(placementId) } earned reward")
    }
}
