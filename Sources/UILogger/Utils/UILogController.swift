#if canImport(UIKit)
import UIKit
#endif

class UILogController: NSObject
{
    var controller: UIViewController
    var action: ControllerAction = .idle
    
    init(controller: UIViewController, action: ControllerAction = .idle)
    {
        self.controller = controller
        self.action = action
    }
    
    var name: String
    {
        controller.name
    }
    
    var isVisible: Bool
    {
        action == .appeared || action == .activated
    }
}
