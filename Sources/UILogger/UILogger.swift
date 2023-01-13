#if canImport(UIKit)
import UIKit
#endif

@objc public protocol UILoggerDelegate: AnyObject
{
    @objc func log(_ log: UILog)
}

@objc public class UILogger: NSObject
{
    // MARK: - Singleton
    @objc public static let shared = UILogger()
    
    // MARK: - Params
    private var currentController: UIViewController?
    private var currentAppeared: String?
    private var observing: Bool = false
    private var appearObserver: Observer?
    private var disappearObserver: Observer?
    private var timer: Timer?
    private var appBackgrounded: Bool = false
    private let recheckInterval: TimeInterval = 2
    private let timerInterval: TimeInterval = 2
    
    // MARK: - Delegate
    public weak var delegate: UILoggerDelegate?
    
    // MARK: - Inits
    override init()
    {
        super.init()
        addLifecycleObservers()
    }
    
    // MARK: - Observing
    @objc public func startObservingControllers()
    {
        observing = true
        checkCurrentController()
    }
    
    @objc public func stopObservingControllers()
    {
        observing = false
        reset()
    }
    
    private func reset()
    {
        currentController = nil
        currentAppeared = nil
        appearObserver?.remove()
        disappearObserver?.remove()
        stopTimer()
    }
    
    private func checkCurrentController()
    {
        guard observing else
        {
            return
        }
        guard let topController = UIApplication.appTopController() else
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + recheckInterval) { [weak self] in
                self?.checkCurrentController()
            }
            return
        }
        guard topController.name != currentController?.name else
        {
            return
        }
        currentController = topController
        appearObserver?.remove()
        disappearObserver?.remove()
        startTimer()
        
        // Add appear observer:
        appearObserver = topController.onViewDidAppear { [weak self] in
            
            self?.controllerAppeared(topController)
        }
        
        // Add disappear observer:
        disappearObserver = topController.onViewDidDisappear { [weak self] in
            
            self?.controllerDissapear(topController)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                
                self?.checkCurrentController()
            }
        }
    }
    
    private func controllerAppeared(_ controller: UIViewController)
    {
        guard controller.name == currentController?.name,
        controller.name != currentAppeared else
        {
            return
        }
        logCurrentController(action: .appeared)
        currentAppeared = controller.name
    }
    
    private func controllerDissapear(_ controller: UIViewController)
    {
        guard controller.name == currentController?.name else
        {
            return
        }
        logCurrentController(action: .disappeared)
    }
    
    // MARK: - Logging
    private func logCurrentController(action: ControllerAction)
    {
        guard let controller = currentController else
        {
            return
        }
        let log = UILog(controller: controller.name, time: Date(), action: action)
        // log.printLog()
        delegate?.log(log)
    }
    
    // MARK: - Deinit
    deinit
    {
        removeLifecycleObservers()
    }
}

// MARK: - Timer
/// This is used to cover up iOS 13 automatic modal presentations that are not fullscreen and which does not invoke methods viewDidAppear and viewDidDisappear
private extension UILogger
{
    func stopTimer()
    {
        timer?.invalidate()
        timer = nil
    }
    
    func startTimer()
    {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true, block: { [weak self] _ in
            
            self?.checkPresentedController()
        })
    }
    
    func checkPresentedController()
    {
        guard let currentController = currentController,
              let presented = currentController.presentedViewController,
              presented.modalPresentationStyle.invokesLifecycleMethods == false else
        {
            return
        }
        stopTimer()
        controllerDissapear(currentController)
        checkCurrentController()
    }
}

// MARK: - App Lifecycle Observers
private extension UILogger
{
    func addLifecycleObservers()
    {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        center.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        center.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        center.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func removeLifecycleObservers()
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didEnterBackground()
    {
    }
    
    @objc func willEnterForeground()
    {
    }
                           
    @objc func willResignActive()
    {
        logCurrentController(action: .backgrounded)
        appBackgrounded = true
    }
    
    @objc func didBecomeActive()
    {
        guard appBackgrounded else
        {
            return
        }
        logCurrentController(action: .foregrounded)
        appBackgrounded = false
    }
}
