import SwiftUI
import XMediator

class ContentViewModel: ObservableObject {
    @Published var mediator: Mediator = XMediatorHelper.shared.mediator {
        didSet {
            XMediatorHelper.shared.mediator = mediator
        }
    }
    @Published var initStatus: InitStatus = .idle
    @Published var loadTriggered: Bool = false
    @Published var cmp: Bool = XMediatorHelper.shared.cmp {
        didSet {
            XMediatorHelper.shared.cmp = cmp
        }
    }
    
    @Published var eeaRegion: Bool = XMediatorHelper.shared.eeaRegion {
        didSet {
            XMediatorHelper.shared.eeaRegion = eeaRegion
        }
    }
    
    private let bannerDelegate = BannerAdsDelegateDemo()
    private let interstitialDelegate = InterstitialAdsDelegateDemo()
    private let appOpenDelegate = AppOpenAdsDelegateDemo()
    private let rewardedDelegate = RewardedAdsDelegateDemo()

    func start() {
        Utils.logger.log("start { app_key: \(self.mediator.appKey), cmp: \(self.cmp), eea_region: \(self.eeaRegion) }")
        initStatus = .initializing
        XMediatorHelper.shared.initialize() { [weak self] result in
            self?.startFinish(result: result)
        }
    }
    
    func loadAds() {
        XMediatorHelper.shared.loadAds()
        loadTriggered = true
    }
    
    func bannerView() -> UIView? {
        XMediatorHelper.shared.bannerView()
    }
    
    func showInterstitial() {
        XMediatorHelper.shared.showInterstitial()
    }
    
    func showAppOpen() {
        XMediatorHelper.shared.showAppOpen()
    }
    
    func showRewarded() {
        XMediatorHelper.shared.showRewarded()
    }
    
    func openDebuggingSuite() {
        XMediatorHelper.shared.openDebuggingSuite()
    }
    
    func launchAppHarbrIntegrationDashboard() {
        XMediatorHelper.shared.launchAppHarbrIntegrationDashboard()
    }
    
    func openCMP() {
        XMediatorHelper.shared.openCMP()
    }
    
    func resetCMP() {
        XMediatorHelper.shared.resetCMP()
    }
    
    func mediators() -> [Mediator] {
        Settings.mediators
    }
    
    private func startFinish(result: Result<Void, Error>) {
        switch result {
        case .success(_):
            setDelegates()
            initStatus = .initialized
        case .failure(_):
            initStatus = .idle
        }
    }
    
    private func setDelegates() {
        XMediatorHelper.shared.setDelegates(bannerAdsDelegate: bannerDelegate, interstitialAdsDelegate: interstitialDelegate, rewardedAdsDelegate: rewardedDelegate, appOpenAdsDelegate: appOpenDelegate)
    }
    
}
