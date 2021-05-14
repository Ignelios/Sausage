import SwiftUI

public struct SausageView<Content: View>: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var sausageEnvironment: SausageEnvironment
    @ObservedObject var sausageHeaderEnvironment: SausageHeaderEnvironment = .shared
    
    // MARK: - Constructor
    
    internal let content: () -> Content
    internal let header: SausageHeaderView?

    public init(
        header: SausageHeaderView? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = header
        self.content = content
    }
    
}

// MARK: - Body

extension SausageView {
    
    public var body: some View {
        ZStack {
            Color.clear
            ZStack {
                backgroundView
                VStack(spacing: 0.0) {
                    headerView
                        .bounds(key: HeaderPreferenceKey.self) { sausageEnvironment.headerHeight = $0.height }
                    scrollableView
                }
                .clipShape( RoundedRectangle(cornerRadius: sausageEnvironment.cornerRadius.value, style: .continuous) )
                .offset(y: sausageEnvironment.yOffsetByLocation)
            }
            
        }
        .bounds(key: ContentPreferenceKey.self) { sausageEnvironment.contentHeight = $0.height }
        .onReceive(sausageEnvironment.$safeArea, perform: { sausageHeaderEnvironment.topPadding = $0.value })
        .animation(sausageEnvironment.animation)
        .environmentObject(sausageEnvironment)
        .edgesIgnoringSafeArea(.vertical)
    }
    
    // TODO: Unique background
    private var backgroundView: some View {
        Color(.systemBackground)
            .clipShape( RoundedRectangle(cornerRadius: sausageEnvironment.cornerRadius.value, style: .continuous) )
            .shadow(radius: 8)
            .offset(y: sausageEnvironment.yOffsetByLocation)
            .gesture(sausageEnvironment.dragGesture)
    }
    
    private var headerView: some View {
        (header ?? .empty)
            .zIndex(1)
            .environmentObject(sausageHeaderEnvironment)
    }
    
    private var scrollableView: some View {
        ScrollViewRepresentable(
            isScrollEnabled: $sausageEnvironment.isInnerScrollEnabled,
            onScrollChanged: $sausageEnvironment.onInnerScrollChanged,
            onScrollEnded: $sausageEnvironment.onInnerScrollEnded,
            isRedrawAvailable: sausageEnvironment.isInnerScrollRedrawAvailable,
            content: content
        )
    }
    
}
