import SwiftUI

extension EdgeInsets {

    init(side: CGFloat) {
        self.init(horizontal: side, vertical: side)
    }

    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }

    static var zero: EdgeInsets { EdgeInsets(horizontal: 0, vertical: 0) }

}
