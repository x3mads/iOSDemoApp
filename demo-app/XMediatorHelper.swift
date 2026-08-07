import XMediator

final class XMediatorHelper {
    static let shared = XMediatorHelper()
    @MainActor var mediator: Mediator = Settings.currentMediator

    private init() {}
    
    func initialize(callback: @escaping (Result<Void, Error>) -> ()) {
        if XMediatorAds.isInitialized() {
            Utils.logger.log("XMediatorHelper Already initialized")
            callback(.success(()))
        }
        else {
            let mediator = Settings.currentMediator
            let cmp = Settings.cmpAutomation
            let eeaRegion = Settings.cmpDebugGeographyOption == .eea
            Utils.logger.log("start { app_key: \(mediator.appKey), cmp: \(cmp), eea_region: \(eeaRegion) }")
            
            ///Note: use these settings for debug only
            let cmpDebugSettings = Settings.cmpDebugGeography == .disabled ? nil : CMPDebugSettings(debugGeography: Settings.cmpDebugGeography)
            let test = Settings.testMode
            let verbose = Settings.verbose
            ///
            
            let consentInformation = ConsentInformation(isCMPAutomationEnabled: cmp, cmpDebugSettings: cmpDebugSettings)
            var customProperties = CustomProperties()
            Settings.customProperties.forEach { property in
                switch property.type {
                case "bool":
                    if let value = Bool(property.value) { customProperties.addBool(key: property.key, value: value) }
                case "int":
                    if let value = Int(property.value) { customProperties.addInt(key: property.key, value: value) }
                case "double":
                    if let value = Double(property.value) { customProperties.addDouble(key: property.key, value: value) }
                case "float":
                    if let value = Float(property.value) { customProperties.addDouble(key: property.key, value: Double(value)) }
                default:
                    customProperties.addString(key: property.key, value: property.value)
                }
            }
            let userProperties = UserProperties(userId: "user_id_demo_app", customProperties: customProperties)
            let initSettings = InitSettings(userProperties: userProperties, consentInformation: consentInformation, test: test, verbose: verbose)
            XMediatorAds.startWith(appKey: mediator.appKey, initSettings: initSettings) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    Utils.logger.log("init success { app_key: \(mediator.appKey) }")
                    Task {
                        await MainActor.run { self.mediator = mediator }
                        await self.loadAds(mediator: mediator)
                        callback(.success(()))
                    }
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

    @MainActor
    func bannerView(adSpace: String = "banner_space") -> UIView? {
        guard let bannerPlacementId = mediator.bannerPlacementId else {
            return nil
        }
        XMediatorAds.banner.setAdSpace(adSpace, forPlacementId: bannerPlacementId)
        return try? XMediatorAds.banner.getView(forPlacementId: bannerPlacementId)
    }

    @MainActor
    func showNative(in containerView: UIView, adSpace: String = "native_space") async {
        guard let nativePlacementId = (Settings.nativeLayoutType == .standard ? mediator.nativeStandardPlacementId : mediator.nativeCompactPlacementId) else { return }
        
        let configuration = NativeRenderConfiguration(layout: Settings.nativeLayoutType.layout())
        await XMediatorAds.native.present(in: containerView,
                                          placementId: nativePlacementId,
                                          configuration: configuration,
                                          adSpace: adSpace)
    }

    @MainActor
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

    @MainActor
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

    @MainActor
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
    
    private func loadAds(mediator: Mediator) async {
        if let bannerPlacementId = mediator.bannerPlacementId {
            await MainActor.run {
                XMediatorAds.banner.create(placementId: bannerPlacementId, size: Settings.bannerSize)
            }
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
