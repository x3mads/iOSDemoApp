import Foundation
import OSLog
import UIKit
import XMediator

struct Utils {
    static let logger = os.Logger(subsystem: "com.x3mads", category: "DEMO_APP")
    
    static func getTopViewController() -> UIViewController? {
        let activeWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first { $0.isKeyWindow }
        let fallbackWindow = activeWindow ??
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        var topController = fallbackWindow?.rootViewController

        while let newTopController = topController?.presentedViewController {
            topController = newTopController
        }
        return topController
    }
}

enum InitStatus {
    case idle
    case initializing
    case initialized
}

enum NativeLayoutType: Hashable {
    case standard
    case compact
    
    func layout() -> NativeLayout {
        switch self {
        case .standard:
            NativeLayout.nib(name: "X3MStandardNativeAdView")
        case .compact:
            NativeLayout.nib(name: "X3MCompactNativeAdView")
        }
    }
    
    func size() -> CGSize {
        switch self {
        case .standard:
            CGSize(width: 320, height: 350)
        case .compact:
            CGSize(width: 320, height: 100)
        }
    }
}
