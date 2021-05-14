import SwiftUI

public enum Anchor {
    case fraction(value: CGFloat, includeOffsets: Bool)
    case height(value: CGFloat)
}
