import SwiftUI

public extension SausageEnvironment {
    
    var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { [unowned self] in
                let location = $0.startLocation.y + self.lastLocation - $0.location.y
                self.onChanged(location)
            }
            .onEnded { [unowned self] in
                let location = $0.startLocation.y - $0.predictedEndLocation.y + self.lastLocation
                self.onEnded(location)
            }
    }

    func onChanged(_ location: CGFloat) {
        
        if shouldApplyGesture(at: location) {
            self.location = location
        } else {
            position(for: location).flatMap { lastLocation = $0.height }
        }
        
        animation = .none
        
    }

    func onEnded(_ location: CGFloat) {
        position(for: location).flatMap { lastLocation = $0.height }
        animation = preferredAnimation ?? .spring(response: 0.2, dampingFraction: 0.9, blendDuration: 0.9)
    }
    
}

private extension SausageEnvironment {
    
    func shouldApplyGesture(at location: CGFloat) -> Bool {
        
        let heights = availablePositions.map { $0.height }
        
        guard let biggest = heights.max(), let lowest = heights.min() else {
            return false
        }
        
        return lowest...biggest ~= location
    }
    
    func position(for location: CGFloat) -> Position? {
        availablePositions
            .enumerated()
            .min(by: { abs($0.element.height - location) < abs($1.element.height - location) } )?
            .element
    }
    
}
