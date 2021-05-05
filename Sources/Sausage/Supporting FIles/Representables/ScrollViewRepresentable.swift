import SwiftUI

public struct ScrollViewRepresentable<Content: View>: UIViewRepresentable {
    
    let axis: Axis
    
    @Binding var isScrollEnabled: Bool
    @Binding var onScrollChanged: CGPoint
    @Binding var onScrollEnded: CGPoint
    
    private var scrollView = UIScrollView()
    private var content: () -> Content
    
    // MARK: - Init
    
    public init(
        axis: Axis,
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
        
        return scrollView
        
    }
    
    public func updateUIView(_ uiView: UIScrollView, context: Context) {
        // uiView.isScrollEnabled = isScrollEnabled
    }
    
    // MARK: - Coordinator
    
    public class Coordinator: NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate {
        
        let context: ScrollViewRepresentable
        
        public init(_ context: ScrollViewRepresentable) {
            self.context = context
        }
        
        // MARK: - ScrollViewDelegate
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard scrollView.contentOffset.y <= 0 || !context.isScrollEnabled else { return }
            scrollView.contentOffset.y = 0
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
            let translation = sender.translation(in: context.scrollView)
            
            if sender.state == .ended {
                context.onScrollEnded = translation.apply(velocity)
            } else {
                context.onScrollChanged = translation
            }
        }
        
    }
    
    public func makeCoordinator() -> Coordinator { .init(self) }

}

private extension CGPoint {
    
    func apply(_ point: CGPoint) -> CGPoint {
        .init(x: x + point.x, y: y + (point.y / 2))
    }
    
}

