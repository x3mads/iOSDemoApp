import SwiftUI
import XMediator

struct NativeView: UIViewRepresentable {
    @EnvironmentObject var viewModel: ContentViewModel
    let adSpace: String
    let containerView = ContainerView.create()

    init(adSpace: String = "native_space") {
        self.adSpace = adSpace
    }

    func makeUIView(context: Context) -> UIView {
        Task { await viewModel.showNative(in: containerView.bridgeView, adSpace: adSpace) }
        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

class ContainerView: UIView {
    let bridgeView = UIView()
    
    static func create() -> Self {
        let containerView = Self()
        containerView.prepare()
        return containerView
    }

    private func prepare() {
        bridgeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bridgeView)

        NSLayoutConstraint.activate([
            bridgeView.topAnchor.constraint(equalTo: topAnchor),
            bridgeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bridgeView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bridgeView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
