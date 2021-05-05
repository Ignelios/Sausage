import SwiftUI

public struct Position {
    
    public enum Style {
        case expanded
        case anchored
        case collapsed
    }
    
    let style: Style
    let height: CGFloat
    
}
