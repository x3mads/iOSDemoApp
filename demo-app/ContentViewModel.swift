import SwiftUI
import XMediator

class ContentViewModel: ObservableObject {
    @Published var mediator: Mediator = XMediatorHelper.shared.mediator {
        didSet {
            XMediatorHelper.shared.mediator = mediator
        }
    }
    @Published var initStatus: InitStatus = .idle
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
    private let nativeDelegate = NativeAdsDelegateDemo()

    func start() {
        initStatus = .initializing
        XMediatorHelper.shared.initialize() { [weak self] result in
            Task {
                await self?.startFinish(result: result)
            }
        }
    }
    
    func bannerView() -> UIView? {
        XMediatorHelper.shared.bannerView()
    }
    
    func showNative(in containerView: UIView) async {
        await XMediatorHelper.shared.showNative(in: containerView)
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
    
    func openCMP() {
        XMediatorHelper.shared.openCMP()
    }
    
    func resetCMP() {
        XMediatorHelper.shared.resetCMP()
    }
    
    func mediators() -> [Mediator] {
        Settings.mediators
    }
    
    @MainActor
    private func startFinish(result: Result<Void, Error>) async {
        switch result {
        case .success(_):
            await setDelegates()
            initStatus = .initialized
        case .failure(_):
            initStatus = .idle
        }
    }
    
    private func setDelegates() async {
        await XMediatorHelper.shared.setDelegates(bannerAdsDelegate: bannerDelegate,
                                                  interstitialAdsDelegate: interstitialDelegate,
                                                  rewardedAdsDelegate: rewardedDelegate,
                                                  appOpenAdsDelegate: appOpenDelegate,
                                                  nativeAdsDelegate: nativeDelegate)
    }
    
}
