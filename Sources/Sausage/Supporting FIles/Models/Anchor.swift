import SwiftUI

public enum Anchor {
    case fraction(value: CGFloat, includeTopOffset: Bool)
    case height(value: CGFloat)
}
