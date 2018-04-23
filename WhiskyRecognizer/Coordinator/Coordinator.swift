//
//  Coordinator.swift
//  Builder
//
//  Created by Akshay Bharath on 12/14/17.
//

import RxCocoa
import RxSwift

struct SceneTransitionStack {
    private var array: [SceneTransitionType] = []
    
    mutating func push(_ element: SceneTransitionType) {
        array.append(element)
    }
    
    mutating func pop() -> SceneTransitionType? {
        return array.popLast()
    }
    
    func peek() -> SceneTransitionType? {
        return array.last
    }
}

class Coordinator: CoordinatorDelegate {
    
    private var window: UIWindow?
    private var transitionStack = SceneTransitionStack()
    private var currentNavigationController: BaseNavigationController?
    private var rootViewController: BaseController?
    
    private(set) var currentController: BaseController?

    // Used to set 'popability'
    private(set) var canBePopped = BehaviorRelay(value: false)
    
    required init(window: UIWindow) {
        self.window = window
    }
    
    required init(navigationController: BaseNavigationController) {
        currentNavigationController = navigationController
    }
    
    required init(controller: BaseController) {
        currentController = controller
    }
    
    func setCurrentNavigationController(to controller: BaseNavigationController?) {
        currentNavigationController = controller
    }
    
    @discardableResult
    func transition(toRoot scene: Scene, shouldEncloseInNavigationController: Bool) -> Completable {
        return transition(to: scene,
                          type: .root,
                          modalTransitionStyle: nil,
                          modalPresentationStyle: nil,
                          shouldEncloseInNavigationController: shouldEncloseInNavigationController)
    }
    
    @discardableResult
    func transition(to scene: Scene, type: SceneTransitionType) -> Completable {
        return transition(to: scene,
                          type: type,
                          modalTransitionStyle: nil,
                          modalPresentationStyle: nil,
                          shouldEncloseInNavigationController: false)
    }
    
    @discardableResult
    func transition(to scene: Scene, modalTransitionStyle: UIModalTransitionStyle) -> Completable {
        return transition(to: scene,
                          type: .modal,
                          modalTransitionStyle: modalTransitionStyle,
                          modalPresentationStyle: nil)
    }
    
    @discardableResult
    func transition(to scene: Scene, modalPresentationStyle: UIModalPresentationStyle) -> Completable {
        return transition(to: scene,
                          type: .modal,
                          modalTransitionStyle: nil,
                          modalPresentationStyle: modalPresentationStyle)
    }
    
    func popToRoot(animated: Bool) {
        currentNavigationController = nil

        if let _ = (rootViewController as? UIViewController)?.presentedViewController {
            (rootViewController as? UIViewController)?.dismiss(animated: animated, completion: nil)
        } else if let rootVC = rootViewController as? UIViewController, let navC = rootVC.naviController as? UINavigationController {
            navC.popToRootViewController(animated: true)
        }
        
        while transitionStack.peek() != .root {
            _ = transitionStack.pop()
        }
        
        currentController = rootViewController
        currentNavigationController = rootViewController?.naviController
    }
    
    @discardableResult
    func pop(animated: Bool) -> Completable {
        let subject = PublishSubject<Void>()
        let mostRecentTransition = transitionStack.pop()
        
        if let currentC = currentController,
            let presenter = currentC.presentingController,
            let type = mostRecentTransition, type == .modal {
            
            // Dismiss controller
            currentC.dismissController(animated: animated) { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                // Set current controller
                strongSelf.currentController = nil
                strongSelf.currentController = Coordinator.actualController(for: presenter)
                if let controller = strongSelf.currentController {
                    print("Current Controller set to \(controller)")
                }
                subject.onCompleted()
                
                // Check and set 'popability'
                if let currC = strongSelf.currentController, currC.presentingController != nil {
                    strongSelf.canBePopped.accept(true)
                } else {
                    strongSelf.canBePopped.accept(false)
                }
            }
            
        } else if let currentC = currentController,
            let navigationController = currentNavigationController,
            let type = mostRecentTransition, type == .push {
            
            // navigate up the stack
            if let uiNavi = navigationController as? UINavigationController {
                // one-off subscription to be notified when pop complete
                _ = uiNavi.rx.delegate
                    .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                    .map { _ in }
                    .bind(to: subject)
            } else {
                subject.onCompleted()
            }
            
            guard navigationController.popController(animated: animated) != nil else {
                fatalError("Can't navigate back from \(currentC)")
            }
            
            guard let lastVC = navigationController.controllers.last else {
                fatalError("There is no last Controller in NavigationController")
            }
            
            // Set current controller
            currentController = nil
            currentController = Coordinator.actualController(for: lastVC)
            if let controller = currentController {
                print("Current Controller set to \(controller)")
            }
            
            // Check and set 'popability'
            if navigationController.childControllers.count > 1 {
                canBePopped.accept(true)
            } else {
                canBePopped.accept(false)
            }
            
        } else if let currentC = currentController {
            fatalError("Not a modal, no NavigationController: can't navigate back from \(currentC)")
        }
        
        return subject.asObservable().take(1).ignoreElements()  // Take at most one emitted element, but don't forward it
    }
}

private extension Coordinator {
    static func actualController(for controller: BaseController?) -> BaseController? {
        if let navigationController = controller as? UINavigationController,
            let firstVC = navigationController.viewControllers.first {
            return firstVC
        } else {
            return controller
        }
    }
    
    @discardableResult
    func transition(to scene: Scene,
                    type: SceneTransitionType,
                    modalTransitionStyle: UIModalTransitionStyle?,
                    modalPresentationStyle: UIModalPresentationStyle?,
                    shouldEncloseInNavigationController: Bool = true) -> Completable {
        
        let subject = PublishSubject<Void>()
        let controller = scene.controller()
        transitionStack.push(type)

        switch type {
        case .root:
            // Make sure we have a navi controller
            guard let window = window else {
                fatalError("No UIWindow object was created")
            }
            
            if rootViewController != nil {
                rootViewController = nil
                currentController = nil
            }
            
            // Create and set rootViewController
            if let controller = controller as? UIViewController, shouldEncloseInNavigationController {
                currentNavigationController = UINavigationController(rootViewController: controller)
                // swiftlint:disable:next force_cast
                window.rootViewController = currentNavigationController as! UINavigationController
            } else if let controller = controller as? UIViewController {
                window.rootViewController = controller
            } else {
                fatalError("Could not set rootViewController")
            }
            
            // make sure root is not poppable then complete
            print("Root Controller set to \(controller)")
            canBePopped.accept(false)
            currentController = Coordinator.actualController(for: window.rootViewController)
            rootViewController = currentController
            subject.onCompleted()
            
        case .push:
            // Make sure we have a navi controller
            guard let navigationController = currentNavigationController else {
                fatalError("Can't push a Controller without a UINavigationController")
            }
            
            if let uiNavi = navigationController as? UINavigationController {
                // one-off subscription to be notified when push complete
                _ = uiNavi.rx.delegate
                    .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                    .map { _ in }
                    .bind(to: subject)
            } else {
                subject.onCompleted()
            }
            
            // Push the one that belongs to scene
            navigationController.pushController(controller: controller, animated: true)
            
            // Set current VC and 'popability'
            canBePopped.accept(true)
            currentController = Coordinator.actualController(for: controller)
            if let controller = currentController {
                print("Current Controller set to \(controller)")
            }
            
        case .modal:
            // Set current view controller to root if nil
            if currentController == nil, let navi = currentNavigationController {
                currentController = navi.visibleController
            } else if currentController == nil, let window = window {
                currentController = window.rootViewController
            }
            
            // Make sure we have a current view controller
            guard let currentC = currentController else {
                fatalError("Current Controller not available")
            }
            
            // Use custom transition or presentation animation
            var cont = controller
            if let tStyle = modalTransitionStyle, let viewController = controller as? UIViewController {
                viewController.modalTransitionStyle = tStyle
                cont = viewController
            }
            if let pStyle = modalPresentationStyle, let viewController = controller as? UIViewController {
                viewController.modalPresentationStyle = pStyle
                if pStyle == .custom {
                    if viewController.transitioningDelegate == nil {
                        viewController.transitioningDelegate = currentC as? UIViewControllerTransitioningDelegate
                    }
                }
                cont = viewController
            }
            
            // Present modally
            currentC.present(controller: cont, animated: true) {
                subject.onCompleted()
            }
            
            // Set current VC and 'popability'
            canBePopped.accept(true)
            currentController = Coordinator.actualController(for: controller)
            if let controller = currentController {
                print("Current Controller set to \(controller)")
            }
        }
        
        return subject.asObservable().take(1).ignoreElements()  // Take at most one emitted element, but don't forward it
    }
}
