import SwiftUI
import XMediator

class ContentViewModel: ObservableObject {
    @Published var mediator: Mediator = Settings.mediators[0]
    @Published var initStatus: InitStatus = .idle
    @Published var cmp: Bool = false
    @Published var eeaRegion: Bool = false
    
    private let bannerDelegate = BannerAdsDelegateDemo()
    private let interstitialDelegate = InterstitialAdsDelegateDemo()
    private let appOpenDelegate = AppOpenAdsDelegateDemo()
    private let rewardedDelegate = RewardedAdsDelegateDemo()

    func start() {
        Utils.logger.log("start { app_key: \(self.mediator.appKey), cmp: \(self.cmp), eea_region: \(self.eeaRegion) }")
        initStatus = .initializing
        
        ///Note: use these settings for debug only
        let cmpDebugSettings = eeaRegion ? CMPDebugSettings(debugGeography: .EEA) : nil
        let test = true
        let verbose = true
        ///
        
        let consentInformation = ConsentInformation(isCMPAutomationEnabled: cmp, cmpDebugSettings: cmpDebugSettings)
        let initSettings = InitSettings(consentInformation: consentInformation, test: test, verbose: verbose)
        XMediatorAds.startWith(appKey: mediator.appKey, initSettings: initSettings) { [weak self] result in
            self?.startFinish(result: result)
        }
    }
    
    func bannerView() -> UIView? {
        guard let bannerPlacementId = mediator.bannerPlacementId else {
            return nil
        }
        return try? XMediatorAds.banner.getView(forPlacementId: bannerPlacementId)
    }
    
    func showInterstitial() {
        guard let placementId = mediator.interstitialPlacementId else {
            return
        }
        if XMediatorAds.interstitial.isReady(withPlacementId: placementId) {
            Utils.getTopViewController().map { XMediatorAds.interstitial.present(withPlacementId: placementId, fromViewController: $0) }
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
            Utils.getTopViewController().map { XMediatorAds.appOpen.present(withPlacementId: placementId, fromViewController: $0) }
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
            Utils.getTopViewController().map { XMediatorAds.rewarded.present(withPlacementId: placementId, fromViewController: $0) }
        }
        else {
            Utils.logger.log("rewarded not ready { placement_id: \(placementId) }")
        }
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
    
    func mediators() -> [Mediator] {
        Settings.mediators
    }
    
    private func startFinish(result: Result<XMediator.InitSuccess, XMediator.InitError>) {
        switch result {
        case .success(_):
            Utils.logger.log("init success { app_key: \(self.mediator.appKey) }")
            initStatus = .initialized
            setDelegates()
            loadAds()
        case .failure(let error):
            Utils.logger.error("init failure { app_key: \(self.mediator.appKey), error: \(error.localizedDescription) }")
            initStatus = .idle
        }
    }
    
    private func setDelegates() {
        XMediatorAds.banner.addDelegate(bannerDelegate)
        XMediatorAds.interstitial.addDelegate(interstitialDelegate)
        XMediatorAds.appOpen.addDelegate(appOpenDelegate)
        XMediatorAds.rewarded.addDelegate(rewardedDelegate)
    }
    
    private func loadAds() {
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
    }
}
