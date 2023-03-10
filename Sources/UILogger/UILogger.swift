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
    private var currentController: UILogController?
    private var observing: Bool = false
    private var stateObserver: Observer?
    private var timer: Timer?
    private let recheckInterval: TimeInterval = 2
    private let timerInterval: TimeInterval = 2
    lazy var timing = UILogTiming()
    
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
        stateObserver?.remove()
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
        guard topController != currentController else
        {
            return
        }
        let previousController = currentController
        currentController = UILogController(controller: topController)
        stateObserver?.remove()
        startTimer()
        
        stateObserver = topController.observeFinishedState { [weak self] in
            
            self?.logPreviousDisappearIfNeeded(previousController)
            self?.controllerAppeared(topController)
            
        } onDidDisappear: { [weak self] in
            
            self?.controllerDissapeared(topController)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                
                self?.checkCurrentController()
            }
        }
    }
    
    private func controllerAppeared(_ controller: UIViewController)
    {
        guard controller.name == currentController?.name else
        {
            return
        }
        logCurrentController(action: .appeared)
    }
    
    private func controllerDissapeared(_ controller: UIViewController)
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
        guard action.isSameLogic(with: controller.action) == false else
        {
            return
        }
        controller.action = action
        let log = UILog(controller: controller.name, time: Date(), action: action)
        processLog(log)
    }
    
    private func logPreviousDisappearIfNeeded(_ previousController: UILogController?)
    {
        guard let previousController = previousController,
              previousController.action.isVisible else
        {
            return
        }
        let log = UILog(controller: previousController.name, time: Date(), action: .disappeared)
        processLog(log)
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
        guard #available(iOS 10.0, *) else
        {
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true, block: { [weak self] _ in
            
            self?.backupCheckings()
        })
    }
    
    func backupCheckings()
    {
        guard let currentController = currentController else
        {
            return
        }
        
        // Check presented controller:
        if let presented = currentController.controller.presentedViewController,
              presented.modalPresentationStyle.invokesLifecycleMethods == false
        {
            stopTimer()
            controllerDissapeared(currentController.controller)
            checkCurrentController()
            return
        }
        
        // Log controller appear action if not yet logged:
        if currentController.action == .idle
        {
            controllerAppeared(currentController.controller)
        }
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
        center.addObserver(self, selector: #selector(willTerminate), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    func removeLifecycleObservers()
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didEnterBackground()
    {
        logCurrentController(action: .backgrounded)
    }
    
    @objc func willEnterForeground()
    {
        logCurrentController(action: .foregrounded)
    }
                           
    @objc func willResignActive()
    {
        logCurrentController(action: .deactivated)
    }
    
    @objc func didBecomeActive()
    {
        logCurrentController(action: .activated)
    }
    
    @objc func willTerminate()
    {
        logCurrentController(action: .terminated)
    }
}
