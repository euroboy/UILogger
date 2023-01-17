import Foundation

struct UILogTiming
{
    var appearTime: Date?
    var disappearTime: Date?
    {
        didSet
        {
            updateDuration()
        }
    }
    var duration: TimeInterval = 0
    
    private mutating func updateDuration()
    {
        guard let appearTime = appearTime,
              let disappearTime = disappearTime else
        {
            return
        }
        let interval = abs(appearTime.timeIntervalSince(disappearTime))
        duration += interval
    }
    
    mutating func reset()
    {
        appearTime = nil
        disappearTime = nil
        duration = 0
    }
}
