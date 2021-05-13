import SwiftUI

public class SausageEnvironment: ObservableObject {
    
    public init(
        animation: Animation? = nil,
        offset: Offset = .default,
        anchor: Anchor = .fraction(value: 0.5, includeTopOffset: true),
        safeArea: SafeArea = .default,
        cornerRadius: CornerRadius = .topByDeviceRadius()
    ) {
        self.animation = animation
        self.anchor = anchor
        self.offset = offset
        self.safeArea = .init(data: safeArea, value: 0.0)
        self.cornerRadius = .init(data: cornerRadius, value: cornerRadius.onAnyOther)
    }
    
    // MARK: - Content
    
    var contentHeight: CGFloat = UIScreen.main.bounds.height
    
    var headerHeight: CGFloat = 0.0
    
    // MARK: - Transition
    
    var location: CGFloat = 0.0 {
        didSet {
            enableInnerScrollIfNeeded()
            updateSausageView()
            updateSafeAreaInset()
            updateCornerRadius()
        }
    }
    
    var lastLocation: CGFloat = 0.0 {
        didSet { location = lastLocation }
    }
    
    @Published var yOffsetByLocation: CGFloat = 0.0
    
    // MARK: - Animation
    
    var animation: Animation?
    
    var preferredAnimation: Animation? = nil
    
    // MARK: - Offsets/Anchor
    
    var offset: Offset
    
    var anchor: Anchor
    
    // MARK: - Inner Scroll
    
    var isInnerScrollEnabled: Bool = false
    
    var onInnerScrollChanged: CGPoint = .init(x: 0, y: 0) {
        // NOTICE: min(x,y) can have some unknown issues.
        didSet { onChanged(min(contentHeight, lastLocation - onInnerScrollChanged.y)) }
    }
    
    var onInnerScrollEnded: CGPoint = .init(x: 0, y: 0) {
        didSet { onEnded(lastLocation - onInnerScrollEnded.y) }
    }
    
    // MARK: - SafeArea
    
    @Published var safeArea: ValueProviding<SafeArea, CGFloat>
    
    // MARK: - CornerRadius
    
    @Published var cornerRadius: ValueProviding<CornerRadius, CGFloat>
}

// MARK: - Helpers

private extension SausageEnvironment {
    
    var anchorFraction: CGFloat {
        let defaultInset: CGFloat = 44
        let fractionTrigger: CGFloat = calculatedTop - defaultInset * 2
        let fraction = location - fractionTrigger
        guard fraction > 0 else { return 0 }
        let fractionDistance = calculatedTop - fractionTrigger
        return (min(1, fraction / fractionDistance))
    }

    func enableInnerScrollIfNeeded() {
        let locationWithTopOffset = location + offset.top
        isInnerScrollEnabled = contentHeight == locationWithTopOffset
    }
    
    func updateSausageView() {
        yOffsetByLocation = contentHeight - location
    }
    
    func updateSafeAreaInset() {
        safeArea.value = max(0, 44 * anchorFraction)
    }
    
    func updateCornerRadius() {
        cornerRadius.value = max(cornerRadius.data.onAnyOther, cornerRadius.data.onTop * anchorFraction)
    }
 
}

// MARK: - API

public extension SausageEnvironment {
    
    func setTopOffset(_ offset: CGFloat) {
        self.offset.top = offset
    }
    
    func setBottomOffset(_ offset: CGFloat) {
        self.offset.bottom = offset
    }
    
    func setAnchor(_ anchor: Anchor) {
        self.anchor = anchor
    }
    
    func setPositionStyle(_ position: Position.Style) {
        guard
            let location = availablePositions
                .first(where: { $0.style == position })?
                .height
        else {
            return
        }

        self.lastLocation = location
    }
    
    func setAnimation(_ animation: Animation) {
        self.preferredAnimation = animation
    }
    
}

// MARK: - Positions

extension SausageEnvironment {
    
    var availablePositions: [Position] {
        [
            .init(style: .expanded, height: calculatedTop),
            .init(style: .anchored, height: calculatedAnchor),
            .init(style: .collapsed, height: calculatedBottom),
        ]
    }
    
    var calculatedTop: CGFloat { contentHeight - offset.top }
    
    var calculatedAnchor: CGFloat {
        switch anchor {
        case let .fraction(value, includeTopOffset):
            
            let correctHeight = includeTopOffset ? contentHeight : calculatedTop
            return correctHeight - (contentHeight * value)
            
        case let .height(value):
            
            return value <= calculatedBottom
                ? calculatedBottom
                : value
        }
    }
    
    var calculatedBottom: CGFloat { offset.bottom + (offset.includeHeaderHeight ? headerHeight : 0.0) }
    
}