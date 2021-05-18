import SwiftUI

public struct Offset {
    
    public struct Top {
        public var value: CGFloat
        public let includeSafeArea: Bool
        
        public init(value: CGFloat, includeSafeArea: Bool) {
            self.value = value
            self.includeSafeArea = includeSafeArea
        }
        
        public static var `default`: Self { .init(value: 0, includeSafeArea: true) }
        
        public var valueWithSafeAreaIfNeeded: CGFloat {
            includeSafeArea
                ? value > 0 ? SafeArea.default.top + value : value
                : value
        }
    }
    
    public struct Bottom {
        public var value: CGFloat
        public let includeSafeArea: Bool
        public let includeHeaderHeight: Bool
        
        public init(value: CGFloat, includeHeaderHeight: Bool, includeSafeArea: Bool) {
            self.value = value
            self.includeHeaderHeight = includeHeaderHeight
            self.includeSafeArea = true
        }
        
        public static var `default`: Self { .init(value: 0, includeHeaderHeight: true, includeSafeArea: true) }
        
        public var valueWithSafeAreaIfNeeded: CGFloat {
            includeSafeArea
                ? value > 0 ? SafeArea.default.top + value : value
                : value
        }
    }
    
    public var top: Top
    public var bottom: Bottom
    
    public init(top: Top = .default, bottom: Bottom = .default) {
        self.top = top
        self.bottom = bottom
    }
    
    public static var `default`: Self { .init(top: .default, bottom: .default) }
}
