import SwiftUI

class SausageHeaderEnvironment: ObservableObject {
    
    static let shared: SausageHeaderEnvironment = .init()
    
    @Published var topPadding: CGFloat = 0
    
}
