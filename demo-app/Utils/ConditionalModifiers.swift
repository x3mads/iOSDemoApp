import SwiftUI

extension View {

    @ViewBuilder
    func apply(@ViewBuilder _ block: (Self) -> some View) -> some View {
        block(self)
    }

    @ViewBuilder
    func hidden(if condition: Bool) -> some View {
        if condition {
            self.hidden()
        } else {
            self
        }
    }

    @ViewBuilder
    func insert(if condition: Bool) -> some View {
        if condition {
            self
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func overlay<Overlay: View>(if condition: Bool,
                                alignment: Alignment = .center,
                                @ViewBuilder overlay: @escaping () -> Overlay) -> some View {
        if condition {
            self.overlay(overlay(), alignment: alignment)
        } else {
            self
        }
    }

    @ViewBuilder
    func frame(if condition: Bool,
               width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment = .center) -> some View {
        if condition {
            self.frame(width: width, height: height, alignment: alignment)
        } else {
            self
        }
    }

    @ViewBuilder
    func frame(if condition: Bool,
               minWidth: CGFloat? = nil, idealWidth: CGFloat? = nil, maxWidth: CGFloat? = nil,
               minHeight: CGFloat? = nil, idealHeight: CGFloat? = nil, maxHeight: CGFloat? = nil, alignment: Alignment = .center) -> some View {
        if condition {
            self.frame(minWidth: minWidth, idealWidth: idealWidth, maxWidth: maxWidth,
                       minHeight: minHeight, idealHeight: idealHeight, maxHeight: maxHeight, alignment: alignment)
        } else {
            self
        }
    }

}
