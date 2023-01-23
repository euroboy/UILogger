import Foundation

extension UILogger
{
    func processLog(_ log: UILog)
    {
        switch log.action
        {
        case .appeared:
            timing.reset()
            timing.appearTime = log.time
        case .disappeared:
            timing.disappearTime = log.time
            log.duration = timing.duration
            timing.reset()
        case .activated:
            timing.appearTime = log.time
        case .deactivated:
            timing.disappearTime = log.time
        case .backgrounded:
            // timing logic is handled by `deactivated` action
            break
        case .foregrounded:
            // timing logic is handled by `activated` action
            break
        case .terminated:
            if timing.disappearTime == nil
            {
                timing.disappearTime = log.time
            }
            log.duration = timing.duration
        default:
            break
        }
        // log.printLog()
        delegate?.log(log)
    }
}
