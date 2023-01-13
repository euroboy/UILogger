#if canImport(UIKit)
import UIKit
#endif

extension UIViewController
{
    var name: String
    {
        String(describing: type(of: self))
    }
}
