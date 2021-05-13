import SwiftUI

public struct SafeArea {
    
    public let top: CGFloat
    public let bottom: CGFloat
    
    init(top: CGFloat, bottom: CGFloat) {
        self.top = top
        self.bottom = bottom
    }
    
    public static var `default`: Self {
        let insets = (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero)
        return .init(top: insets.top, bottom: insets.bottom)
    }
    
    public static var none: Self { .init(top: 0, bottom: 0) }
    
}
