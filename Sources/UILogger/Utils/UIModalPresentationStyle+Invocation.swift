#if canImport(UIKit)
import UIKit
#endif

extension UIModalPresentationStyle
{
    var invokesLifecycleMethods: Bool
    {
        guard #available(iOS 13.0, *) else
        {
            return false
        }
        let invocationStyles: [UIModalPresentationStyle] = [.fullScreen, .currentContext]
        return invocationStyles.contains(self)
    }
}

