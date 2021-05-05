import SwiftUI

public struct Sausage<Content: View>: View {
    
    @ObservedObject var state = SausageState()
    
    internal let content: () -> Content

    public init(position: Position.Style = .anchored, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.state.preferredPositionStyle = position
    }
    
}

// MARK: - Body

struct ContentPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { defaultValue = nextValue() }
}

// TODO: Device body and background logic. Maybe allow to provider unique background via constructor.
public extension Sausage {
    
    var body: some View {
        ZStack {
            
            Color.clear
            
            ZStack {
                
                // TODO: Unique backgroud
                Color(.systemBackground)
                    .cornerRadius(radius: 20, corners: [.topLeft, .topRight])
                    .shadow(radius: 8)
                    .offset(y: state.currentOffsetY)
                    .gesture(state.dragGesture)
                    
                ScrollViewRepresentable(
                    axis: .vertical,
                    isScrollEnabled: $state.isScrollEnabled,
                    onScrollChanged: $state.onScrollChanged,
                    onScrollEnded: $state.onScrollEnded,
                    content: content
                )
                .cornerRadius(radius: 20, corners: [.topLeft, .topRight])
                .offset(y: state.currentOffsetY)
                .padding(.top, 88)
                
            }
            
        }
        .bounds(key: ContentPreferenceKey.self) { state.contentHeight = $0.height }
        .cornerRadius(radius: 20, corners: [.topLeft, .topRight])
        .animation(state.currentAnimation)
        .edgesIgnoringSafeArea(.vertical)
    }

    
    // TODO: Implement header
    
    // -
}
