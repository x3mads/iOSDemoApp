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
                 appKey: "V148L42DRG",
                 bannerPlacementId: "V142XB3LRNZCM7",
                 interstitialPlacementId: "V142XBGL601BCD",
                 appOpenPlacementId: "V14JHR48HLHAQ304",
                 rewardedPlacementId: "V142DRKLYD2CVX",
                 nativeStandardPlacementId: "V14CHR2V3LDA0Q4H"),
        Mediator(name: "LevelPlay",
                 appKey: "V148L42DR3",
                 bannerPlacementId: "V142YBZL36TNH7",
                 interstitialPlacementId: "V142YB3L1J9DKT",
                 rewardedPlacementId: "V142YBGLYF22ST",
                 nativeCompactPlacementId: "V14CHR2V2LNGAA5Z",
                 nativeStandardPlacementId: "V14CHR2V2LNGAA5Z"),
        Mediator(name: "AdMob",
                 appKey: "V148L48DB9",
                 bannerPlacementId: "V14JHR4VKLPYKX70",
                 interstitialPlacementId: "V14JHR4V2LCPBMMY",
                 appOpenPlacementId: "V14JHR4VHLG8A741",
                 rewardedPlacementId: "V14JHR4V3L78QZQ2",
                 nativeCompactPlacementId: "V14CHR283LHF2D38",
                 nativeStandardPlacementId: "V14CHR282LMQFCPE"),
        ///Note: add your configuration here
        Mediator(name: "Custom",
                 appKey: "<replace>",
                 bannerPlacementId: "<replace_or_nil>",
                 interstitialPlacementId: "<replace_or_nil>",
                 appOpenPlacementId: "<replace_or_nil>",
                 rewardedPlacementId: "<replace_or_nil>",
                 nativeStandardPlacementId: "<replace_or_nil>")
    ]
    
    static let bannerSize: Banner.Size = UIDevice.current.userInterfaceIdiom == .phone ? .phone : .tablet
    
    ///Note: choose the design
    static let nativeLayoutType: NativeLayoutType = .standard
}

struct Mediator: Hashable {
    let name: String
    let appKey: String
    let bannerPlacementId: String?
    let interstitialPlacementId: String?
    let appOpenPlacementId: String?
    let rewardedPlacementId: String?
    let nativeCompactPlacementId: String?
    let nativeStandardPlacementId: String?
    
    init(name: String,
         appKey: String,
         bannerPlacementId: String? = nil,
         interstitialPlacementId: String? = nil,
         appOpenPlacementId: String? = nil,
         rewardedPlacementId: String? = nil,
         nativeCompactPlacementId: String? = nil,
         nativeStandardPlacementId: String? = nil) {
        self.name = name
        self.appKey = appKey
        self.bannerPlacementId = bannerPlacementId
        self.interstitialPlacementId = interstitialPlacementId
        self.appOpenPlacementId = appOpenPlacementId
        self.rewardedPlacementId = rewardedPlacementId
        self.nativeCompactPlacementId = nativeCompactPlacementId
        self.nativeStandardPlacementId = nativeStandardPlacementId
    }
}
