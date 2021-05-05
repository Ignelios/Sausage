import SwiftUI

// TODO: Implement position style based corner radius.

public class SausageState: ObservableObject {
    
    var contentHeight: CGFloat = UIScreen.main.bounds.height
    
    // MARK: Position
    
    var preferredPositionStyle: Position.Style = .collapsed {
        didSet { position = availablePositions.first { $0.style == preferredPositionStyle }! }
    }
    
    var position: Position = .init(style: .collapsed, height: 0) {
        didSet {
            // TODO: Not nice
            currentHeight = position.height
        }
    }
    
    var currentHeight: CGFloat = 0.0 {
        didSet {
            currentOffsetY = contentHeight - currentHeight
            // TODO: Not nice
            isScrollEnabled = contentHeight == currentHeight + topOffset
        }
    }
    
    // TODO: Make these available via environment variables.
    var topOffset: CGFloat = 100
    var bottomOffset: CGFloat = 100
    var anchor: Anchor = .fraction(value: 0.5, includeTopOffset: true)
    
    // MARK: Animations
    
    @Published var currentOffsetY: CGFloat = 0.0
    
    var currentAnimation: Animation? = .none
    
    // MARK: - ScrollView
    
    var outerOffsetY: CGFloat = 0.0
    
    var isScrollEnabled: Bool = false
    
    var onScrollChanged: CGPoint = .init(x: 0, y: 0) {
        didSet { onChanged(position.height - onScrollChanged.y) }
    }
    
    var onScrollEnded: CGPoint = .init(x: 0, y: 0) {
        didSet { onEnded(position.height - onScrollEnded.y) }
    }
    
}

// MARK: - Positions

extension SausageState {
    
    var availablePositions: [Position] {
        [
            .init(style: .expanded, height: calculateTop),
            .init(style: .anchored, height: calculateAnchor),
            .init(style: .collapsed, height: calculateBottom),
        ]
    }
    
    var calculateTop: CGFloat { contentHeight - topOffset }
    
    var calculateAnchor: CGFloat {
        switch anchor {
        case let .fraction(value, includeTopOffset):
            
            let correctHeight = includeTopOffset ? contentHeight : calculateTop
            return correctHeight - (contentHeight * value)
            
        case let .height(value):
            
            return value <= calculateBottom
                ? calculateBottom
                : value
        }
    }
    
    var calculateBottom: CGFloat { bottomOffset }
    
}
