import SwiftUI
import XMediator

@MainActor
final class ContentViewModel: ObservableObject {
    private let adsStore: AdsStore

    @Published var mediator: Mediator = XMediatorHelper.shared.mediator {
        didSet {
            XMediatorHelper.shared.mediator = mediator
            adsStore.update(mediator: mediator)
        }
    }
    @Published var initStatus: InitStatus = .idle
    
    private let bannerDelegate: BannerAdsDelegateDemo
    private let interstitialDelegate: InterstitialAdsDelegateDemo
    private let appOpenDelegate: AppOpenAdsDelegateDemo
    private let rewardedDelegate: RewardedAdsDelegateDemo
    private let nativeDelegate: NativeAdsDelegateDemo

    init(adsStore: AdsStore) {
        self.adsStore = adsStore
        self.bannerDelegate = BannerAdsDelegateDemo(store: adsStore)
        self.interstitialDelegate = InterstitialAdsDelegateDemo(store: adsStore)
        self.appOpenDelegate = AppOpenAdsDelegateDemo(store: adsStore)
        self.rewardedDelegate = RewardedAdsDelegateDemo(store: adsStore)
        self.nativeDelegate = NativeAdsDelegateDemo(store: adsStore)
    }

    func start() {
        initStatus = .initializing
        Task { @MainActor [weak self] in
            guard let self else { return }
            await setDelegates()
            XMediatorHelper.shared.initialize() { [weak self] result in
                Task { @MainActor in
                    await self?.startFinish(result: result)
                }
            }
        }
    }
    
    func bannerView(adSpace: String = "banner_space") -> UIView? {
        XMediatorHelper.shared.bannerView(adSpace: adSpace)
    }
    
    func showNative(in containerView: UIView, adSpace: String = "native_space") async {
        await XMediatorHelper.shared.showNative(in: containerView, adSpace: adSpace)
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
            await adsStore.refreshReadiness()
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
