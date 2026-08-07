import SwiftUI
import UIKit

struct NavBarStyle {
    static func setUp() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: Colors.UIKit.primaryTitle]
        appearance.largeTitleTextAttributes = [.foregroundColor: Colors.UIKit.primaryTitle]
        appearance.backgroundColor = Colors.UIKit.primaryBackground

        if #available(iOS 26, *) {
            let transparent = UINavigationBarAppearance()
            transparent.configureWithTransparentBackground()
            transparent.titleTextAttributes = [.foregroundColor: Colors.UIKit.primaryTitle]
            transparent.largeTitleTextAttributes = [.foregroundColor: Colors.UIKit.primaryTitle]

            UINavigationBar.appearance().standardAppearance = transparent
            UINavigationBar.appearance().scrollEdgeAppearance = transparent
            UINavigationBar.appearance().compactAppearance = transparent
        } else {
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
        }
        UINavigationBar.appearance().tintColor = Colors.UIKit.primaryText
        UINavigationBar.appearance().tintAdjustmentMode = .normal
    }
}
