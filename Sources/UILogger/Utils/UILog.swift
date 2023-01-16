import Foundation

public enum ControllerAction: String, Codable
{
    case idle
    case appeared
    case disappeared
    case deactivated
    case activated
    
    var isVisible: Bool
    {
        [.appeared, .activated].contains(self)
    }
    
    func isSameLogic(with action: ControllerAction) -> Bool
    {
        if self == action
        {
            return true
        }
        if [self, action].contains(.idle)
        {
            return false
        }
        return self.isVisible == action.isVisible
    }
}

@objc public class UILog: NSObject, Codable
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
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey
    {
        case controller
        case time
        case action
    }
    
    public required init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        controller = try values.decode(String.self, forKey: .controller)
        time = try values.decode(Date.self, forKey: .time)
        action = try values.decode(ControllerAction.self, forKey: .action)
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(controller, forKey: .controller)
        try container.encode(time, forKey: .time)
        try container.encode(action, forKey: .action)
    }
}
