import UIKit

struct SegmentedControlStyle {
    static func setUpSegmentedControl(linesNumber: Int = 1) {
        UISegmentedControl.appearance().selectedSegmentTintColor = .white
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        UISegmentedControl.appearance().backgroundColor = .lightGray
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = linesNumber
    }
}
