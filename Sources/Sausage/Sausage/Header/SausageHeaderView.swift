import SwiftUI

public struct SausageHeaderView: View {
    
    private let content: AnyView
    @EnvironmentObject var headerEnvironment: SausageHeaderEnvironment
    
    public init<Content: View>(@ViewBuilder content: @escaping () -> Content) {
        self.content = AnyView(content())
    }
    
    public var body: some View {
        // TODO: Handle top padding when there are no valid safeArea insets.
        VStack(spacing: 0.0) {
            Rectangle()
                .fill(Color.clear)
                .frame(height: headerEnvironment.topPadding)
            
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(.systemGray6))
                .frame(width: 36, height: 4)
                .padding(.top, 8)
                
            content
                
        }
    }
    
}

extension SausageHeaderView {
    
    static var empty: Self { .init { EmptyView() } }
    
}
