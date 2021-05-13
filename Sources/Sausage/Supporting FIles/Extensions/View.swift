import SwiftUI

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {

    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( withAnimation { RoundedCorner(radius: radius, corners: corners) } )
    }
    
    func bounds<Key: PreferenceKey>(key: Key.Type, output: @escaping (Key.Value) -> ()) -> some View where Key.Value == CGRect {
        background(
            GeometryReader {
                Color.clear.preference(key: key, value: $0.frame(in: .global))
            }
        )
        .onPreferenceChange(key) { output($0) }
    }
    
}
