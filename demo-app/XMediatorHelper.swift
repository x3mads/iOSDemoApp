import XMediator

class XMediatorHelper {
    static let shared = XMediatorHelper()
    var mediator: Mediator = Settings.mediators[0]
    var cmp: Bool = false
    var eeaRegion: Bool = false
    
    private init() {}
    
    func initialize(callback: @escaping (Result<Void, Error>) -> ()) {
        if XMediatorAds.isInitialized() {
            Utils.logger.log("XMediatorHelper Already initialized")
        }
        else {
            Utils.logger.log("start { app_key: \(self.mediator.appKey), cmp: \(self.cmp), eea_region: \(self.eeaRegion) }")
            
            ///Note: use these settings for debug only
            let cmpDebugSettings = eeaRegion ? CMPDebugSettings(debugGeography: .EEA) : nil
            let test = true
            let verbose = true
            ///
            
            let consentInformation = ConsentInformation(isCMPAutomationEnabled: cmp, cmpDebugSettings: cmpDebugSettings)
            let userProperties = UserProperties(userId: "user_id_demo_app")
            let initSettings = InitSettings(userProperties: userProperties, consentInformation: consentInformation, test: test, verbose: verbose)
            XMediatorAds.startWith(appKey: mediator.appKey, initSettings: initSettings) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    Utils.logger.log("init success { app_key: \(self.mediator.appKey) }")
                    self.loadAds(mediator: self.mediator)
                    callback(.success(()))
                case .failure(let error):
                    Utils.logger.error("init failure { app_key: \(mediator.appKey), error: \(error.localizedDescription) }")
                    callback(.failure(error))
                }
            }
        }
    }
    
    func setDelegates(bannerAdsDelegate: BannerAdsDelegate,
                      interstitialAdsDelegate: InterstitialAdsDelegate,
                      rewardedAdsDelegate: RewardedAdsDelegate,
                      appOpenAdsDelegate: AppOpenAdsDelegate,
                      nativeAdsDelegate: NativeAdsDelegate) async {
        XMediatorAds.banner.addDelegate(bannerAdsDelegate)
        XMediatorAds.interstitial.addDelegate(interstitialAdsDelegate)
        XMediatorAds.rewarded.addDelegate(rewardedAdsDelegate)
        XMediatorAds.appOpen.addDelegate(appOpenAdsDelegate)
        await XMediatorAds.native.addDelegate(nativeAdsDelegate)
    }
    
    func openDebuggingSuite() {
        XMediatorAds.openDebuggingSuite()
    }
    
    func openCMP() {
        Utils.getTopViewController().map { XMediatorAds.cmpProvider.presentPrivacyForm(fromViewController: $0) { error in
            error.map { Utils.logger.log("cmp could not be displayed. error: \($0)") }
        }}
    }
    
    func resetCMP() {
        XMediatorAds.cmpProvider.reset()
    }
    
    func bannerView() -> UIView? {
        guard let bannerPlacementId = mediator.bannerPlacementId else {
            return nil
        }
        XMediatorAds.banner.setAdSpace("banner_space", forPlacementId: bannerPlacementId)
        return try? XMediatorAds.banner.getView(forPlacementId: bannerPlacementId)
    }
    
    func showNative(in containerView: UIView) async {
        guard let nativePlacementId = (Settings.nativeLayoutType == .standard ? mediator.nativeStandardPlacementId : mediator.nativeCompactPlacementId) else { return }
        
        let configuration = NativeRenderConfiguration(layout: Settings.nativeLayoutType.layout())
        await XMediatorAds.native.present(in: containerView,
                                          placementId: nativePlacementId,
                                          configuration: configuration,
                                          adSpace: "native_space")
    }
    
    func showInterstitial() {
        guard let placementId = mediator.interstitialPlacementId else {
            return
        }
        if XMediatorAds.interstitial.isReady(withPlacementId: placementId) {
            Utils.getTopViewController().map { XMediatorAds.interstitial.present(withPlacementId: placementId,
                                                                                 fromViewController: $0,
                                                                                 fromAdSpace: "interstitial_space") }
        }
        else {
            Utils.logger.log("interstitial not ready { placement_id: \(placementId) }")
        }
    }
    
    func showAppOpen() {
        guard let placementId = mediator.appOpenPlacementId else {
            return
        }
        if XMediatorAds.appOpen.isReady(withPlacementId: placementId) {
            Utils.getTopViewController().map { XMediatorAds.appOpen.present(withPlacementId: placementId,
                                                                            fromViewController: $0,
                                                                            fromAdSpace: "appopen_space") }
        }
        else {
            Utils.logger.log("app_open not ready { placement_id: \(placementId) }")
        }
    }
    
    func showRewarded() {
        guard let placementId = mediator.rewardedPlacementId else {
            return
        }
        if XMediatorAds.rewarded.isReady(withPlacementId: placementId) {
            Utils.getTopViewController().map { XMediatorAds.rewarded.present(withPlacementId: placementId,
                                                                             fromViewController: $0,
                                                                             fromAdSpace: "rewarded_space") }
        }
        else {
            Utils.logger.log("rewarded not ready { placement_id: \(placementId) }")
        }
    }
    
    private func loadAds(mediator: Mediator) {
        if let bannerPlacementId = mediator.bannerPlacementId {
            XMediatorAds.banner.create(placementId: bannerPlacementId, size: Settings.bannerSize)
            Utils.logger.log("banner loading { placement_id: \(bannerPlacementId) }")
        }

        if let interstitialPlacementId = mediator.interstitialPlacementId {
            XMediatorAds.interstitial.load(placementId: interstitialPlacementId)
            Utils.logger.log("interstitial loading { placement_id: \(interstitialPlacementId) }")
        }
        
        if let appOpenPlacementId = mediator.appOpenPlacementId {
            XMediatorAds.appOpen.load(placementId: appOpenPlacementId)
            Utils.logger.log("app_open loading { placement_id: \(appOpenPlacementId) }")
        }

        if let rewardedPlacementId = mediator.rewardedPlacementId {
            XMediatorAds.rewarded.load(placementId: rewardedPlacementId)
            Utils.logger.log("rewarded loading { placement_id: \(rewardedPlacementId) }")
        }
        
        if let nativePlacementId = Settings.nativeLayoutType == .standard ? mediator.nativeStandardPlacementId : mediator.nativeCompactPlacementId {
            Task {
                await XMediatorAds.native.load(placementId: nativePlacementId)
            }
            Utils.logger.log("native loading { placement_id: \(nativePlacementId) }")
        }
    }
}
