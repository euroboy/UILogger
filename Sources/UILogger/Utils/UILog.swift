import Foundation

public enum ControllerAction: String
{
    case appeared
    case disappeared
    case backgrounded
    case foregrounded
}

@objc public class UILog: NSObject
{
    public var controller: String
    public var time: Date
    public var action: ControllerAction
    
    init(controller: String, time: Date, action: ControllerAction)
    {
        self.controller = controller
        self.time = time
        self.action = action
    }
    
    public func printLog()
    {
        let marker = "**********"
        let message = marker + " " + controller + " " + action.rawValue.uppercased() + " " + marker
        print(message)
    }
}
