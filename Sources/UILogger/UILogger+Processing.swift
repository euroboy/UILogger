import Foundation

extension UILogger
{
    func processLog(_ log: UILog)
    {
        switch log.action
        {
        case .appeared:
            timing.appearTime = log.time
            timing.duration = 0
            delegate?.logInAppNavigation(log)
        case .disappeared:
            timing.disappearTime = log.time
            log.duration = timing.duration
            delegate?.logInAppNavigation(log)
        case .activated:
            timing.appearTime = log.time
            delegate?.logAllNavigation(log)
        case .deactivated:
            timing.disappearTime = log.time
            delegate?.logAllNavigation(log)
        default:
            break
        }
        // log.printLog()
    }
}
