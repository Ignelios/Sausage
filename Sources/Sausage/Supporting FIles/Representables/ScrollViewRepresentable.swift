import SwiftUI

public struct ScrollViewRepresentable<Content: View>: UIViewRepresentable {
    
    let axis: Axis
    
    @Binding var isScrollEnabled: Bool
    @Binding var onScrollChanged: CGPoint
    @Binding var onScrollEnded: CGPoint
    
    var scrollView = UIScrollView()
    var content: () -> Content
    
    // MARK: - Init
    
    public init(
        axis: Axis = .vertical,
        isScrollEnabled: Binding<Bool> = .constant(true),
        onScrollChanged: Binding<CGPoint>,
        onScrollEnded: Binding<CGPoint>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self._isScrollEnabled = isScrollEnabled
        self._onScrollChanged = onScrollChanged
        self._onScrollEnded = onScrollEnded
        self.content = content
    }
    
    // MARK: - UIViewRepresentable
    
    public func makeUIView(context: Context) -> UIScrollView {
        
        // Gesture
        
        let dragGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.draggedView(_:)))
        dragGesture.delegate = context.coordinator
        scrollView.isUserInteractionEnabled = true
        scrollView.addGestureRecognizer(dragGesture)
        
        // ScrollView
        
        setupHostingView(for: scrollView, context: context)
        
        return scrollView
        
    }
    
    public func updateUIView(_ scrollView: UIScrollView, context: Context) {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        setupHostingView(for: scrollView, context: context)
    }
    
    private func setupHostingView(for scrollView: UIScrollView, context: Context) {
        
        let hosting = UIHostingController(rootView: content())
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.delegate = context.coordinator
        scrollView.addSubview(hosting.view)
        
        let constraints: [NSLayoutConstraint]
        switch axis {
        case .horizontal:
            constraints = [
                hosting.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
                hosting.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
                hosting.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
                hosting.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                hosting.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            ]
        case .vertical:
            constraints = [
                hosting.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                hosting.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                hosting.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                hosting.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
                hosting.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ]
        }
        
        scrollView.addConstraints(constraints)
    }
    
    // MARK: - Coordinator
    
    public class Coordinator: NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate {
        
        let context: ScrollViewRepresentable
        private var ignoredOffset: CGFloat? = nil
        
        public init(_ context: ScrollViewRepresentable) {
            self.context = context
        }
        
        // MARK: - ScrollViewDelegate
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard scrollView.contentOffset.y <= 0 || !context.isScrollEnabled else { return }
            scrollView.contentOffset.y = 0
        }
        
        // TODO: Disable scroll if content is not stretched
        public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            ignoredOffset = nil
            guard !context.isScrollEnabled else { return }
            scrollView.setContentOffset(.zero, animated: false)
        }
        
        public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
            ignoredOffset = nil
        }
        
        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            ignoredOffset = scrollView.contentOffset.y
        }
        
        // MARK: - GestureRecognizerDelegate
        
        public func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            true
        }
                
        // MARK: -
        
        @objc func draggedView(_ sender: UIPanGestureRecognizer) {
            
            if context.isScrollEnabled && context.scrollView.contentOffset.y > 1 { return }
            
            let velocity = sender.velocity(in: context.scrollView)
            var translation = sender.translation(in: context.scrollView)
            translation = CGPoint(x: translation.x, y: translation.y + -(ignoredOffset ?? 0.0))
            
            guard sender.state == .ended else {
                context.onScrollChanged = translation
                return
            }
            
            context.onScrollEnded = translation.apply(velocity)
        }
        
    }
    
    public func makeCoordinator() -> Coordinator { .init(self) }

}

private extension CGPoint {
    
    func apply(_ point: CGPoint) -> CGPoint {
        .init(x: x + point.x, y: y + (point.y / 2))
    }
    
}
