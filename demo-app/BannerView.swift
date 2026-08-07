import SwiftUI
import XMediator

struct BannerView: UIViewRepresentable {
    @EnvironmentObject var viewModel: ContentViewModel
    let adSpace: String
    private let containerView = UIView(frame: CGRect(origin: .zero, size: Settings.bannerSize.get()))

    init(adSpace: String = "banner_space") {
        self.adSpace = adSpace
    }

    typealias UIViewType = UIView

    func makeUIView(context: Context) -> UIView {
        if let bannerView = viewModel.bannerView(adSpace: adSpace) {
            containerView.addSubview(bannerView)
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            bannerView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor).isActive = true
            bannerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        }
        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
