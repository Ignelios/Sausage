import SwiftUI

public extension SausageState {
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { [unowned self] in
                let location = $0.startLocation.y + self.position.height - $0.location.y
                self.onChanged(location)
            }
            .onEnded { [unowned self] in
                let location = $0.startLocation.y - $0.predictedEndLocation.y + self.position.height
                self.onEnded(location)
            }
    }

    func onChanged(_ location: CGFloat) {
        
        if shouldApplyGesture(at: location) {
            currentHeight = location
        } else {
            position(for: location).flatMap { position = $0 }
        }
        
        currentAnimation = .none
        outerOffsetY = location
        
        //print("onChange: \(location)")
    }

    func onEnded(_ location: CGFloat) {
        position(for: location).flatMap { position = $0 }
        currentAnimation = .spring(response: 0.2, dampingFraction: 0.9, blendDuration: 0.9)
        //print("onEnded: \(state.position)")
    }
    
}

private extension SausageState {
    
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
