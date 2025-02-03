import Foundation
import XMediator

struct Settings {
    static let mediators = [
        Mediator(name: "X3M",
                 appKey: "3-15",
                 bannerPlacementId: "3-15/28",
                 interstitialPlacementId: "3-15/26",
                 rewardedPlacementId: "3-15/27"),
        Mediator(name: "MAX",
                 appKey: "3-180",
                 bannerPlacementId: "3-180/1150",
                 interstitialPlacementId: "3-180/1151",
                 rewardedPlacementId: "3-180/1152"),
        Mediator(name: "LevelPlay",
                 appKey: "3-181",
                 bannerPlacementId: "3-181/1153",
                 interstitialPlacementId: "3-181/1154",
                 rewardedPlacementId: "3-181/1155"),
        ///Note: add your configuration here
        Mediator(name: "Custom",
                 appKey: "<replace>",
                 bannerPlacementId: "<replace_or_nil>",
                 interstitialPlacementId: "<replace_or_nil>",
                 rewardedPlacementId: "<replace_or_nil>")
    ]
    
    static let bannerSize: Banner.Size = UIDevice.current.userInterfaceIdiom == .phone ? .phone : .tablet
}

struct Mediator: Hashable {
    let name: String
    let appKey: String
    let bannerPlacementId: String?
    let interstitialPlacementId: String?
    let rewardedPlacementId: String?
    
    init(name: String, appKey: String, bannerPlacementId: String? = nil, interstitialPlacementId: String? = nil, rewardedPlacementId: String? = nil) {
        self.name = name
        self.appKey = appKey
        self.bannerPlacementId = bannerPlacementId
        self.interstitialPlacementId = interstitialPlacementId
        self.rewardedPlacementId = rewardedPlacementId
    }
}
