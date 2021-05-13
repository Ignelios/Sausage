import SwiftUI

public struct Offset {
    
    public var top: CGFloat
    public var bottom: CGFloat
    public let includeHeaderHeight: Bool
    
    public init(
        top: CGFloat,
        bottom: CGFloat,
        includeHeaderHeight: Bool
    ) {
        self.top = top
        self.bottom = bottom
        self.includeHeaderHeight = includeHeaderHeight
    }
    
    public static var `default`: Self { .init(top: 0.0, bottom: 0.0, includeHeaderHeight: true) }
}
