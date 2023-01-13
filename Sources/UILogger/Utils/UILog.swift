import Foundation

enum ControllerAction: String
{
    case appeared
    case disappeared
    case backgrounded
    case foregrounded
}

@objc public class UILog: NSObject
{
    var controller: String
    var time: Date
    var action: ControllerAction
    
    init(controller: String, time: Date, action: ControllerAction)
    {
        self.controller = controller
        self.time = time
        self.action = action
    }
    
    func printLog()
    {
        let marker = "**********"
        let message = marker + " " + controller + " " + action.rawValue.uppercased() + " " + marker
        print(message)
    }
}
