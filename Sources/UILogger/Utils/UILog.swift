import Foundation

enum ControllerAction: String
{
    case appeared
    case disappeared
    case backgrounded
    case foregrounded
}

struct UILog
{
    var controller: String
    var time: Date
    var action: ControllerAction
    
    func printLog()
    {
        let marker = "**********"
        let message = marker + " " + controller + " " + action.rawValue.uppercased() + " " + marker
        print(message)
    }
}
