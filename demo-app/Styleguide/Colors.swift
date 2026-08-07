import SwiftUI

struct Colors {

    static let loomitGreen = Color(hex: "#00FFB6")
    static let loomitLimeGreen = Color(hex: "#D0EF3D")
    static let loomitBlue = Color(hex: "#024A5E")
    static let loomitDarkBlue = Color(hex: "#012A36")
    static let loomitSurfaceVariant = Color(hex: "#033D4D")
    static let loomitOnSurfaceVariant = Color(hex: "#FFFFFFB3")
    static let loomitOutline = Color(hex: "#FFFFFF66")
    static let loomitError = Color(hex: "#CF6679")

    static let primaryBackground = loomitDarkBlue
    static let secondaryBackground = loomitBlue
    static let tertiaryBackground = Color(hex: "#081C25")
    static let errorBackground = Color(hex: "8B1E1E")
    static let primaryTitle = loomitGreen
    static let secondaryTitle = Color.white
    static let text = Color(hex: "#B7C7CD")
    static let secondaryText = Color(hex: "#AFAFAF")
    static let textFieldText = Color(lightMode: UIColor.black, darkMode: UIColor.white)
    static let textFieldBackground = Color(lightMode: UIColor.white, darkMode: UIColor.black)

    struct UIKit {
        static let primaryTitle = UIColor(hex: "#00FFB6")
        static let primaryText = UIColor(hex: "#B7C7CD")
        static let primaryBackground = UIColor(hex: "#012A36")
    }

}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Creates an adaptive Color that swaps automatically between light and dark modes.
    @available(iOS 14.0, *)
    init(lightMode: Color, darkMode: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(darkMode)
            default:
                return UIColor(lightMode)
            }
        })
    }

    /// Creates an adaptive Color that swaps automatically between light and dark modes.
    init(lightMode: UIColor, darkMode: UIColor) {
        self.init(lightMode: Color(lightMode), darkMode: Color(darkMode))
    }

}

extension UIColor {
    convenience init(hex: String) {
        let r, g, b, a: CGFloat

        var hexColor = hex
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            hexColor = String(hex[start...])
        }
        if hexColor.count == 6 {
            hexColor += "FF"
        }
        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                a = CGFloat(hexNumber & 0x000000ff) / 255

                self.init(red: r, green: g, blue: b, alpha: a)
                return
            }
        }

        self.init(white: 0, alpha: 0)
    }
}
