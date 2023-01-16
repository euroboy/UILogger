#if canImport(UIKit)
import UIKit
#endif

extension UIApplication
{
    class func appTopController(controller: UIViewController? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController) -> UIViewController?
    {
        if let navigationController = controller as? UINavigationController
        {
            return appTopController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController
        {
            if let selected = tabController.selectedViewController
            {
                return appTopController(controller: selected)
            }
        }
        if let pageController = controller as? UIPageViewController
        {
            if let selected = pageController.viewControllers?.first
            {
                return appTopController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController
        {
            return appTopController(controller: presented)
        }
        return controller
    }
}
