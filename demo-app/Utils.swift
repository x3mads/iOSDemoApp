import Foundation
import OSLog
import UIKit

struct Utils {
    static let logger = os.Logger(subsystem: "com.x3mads", category: "DEMO_APP")
    
    static func getTopViewController() -> UIViewController? {
        var topController = UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }.last
        
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
