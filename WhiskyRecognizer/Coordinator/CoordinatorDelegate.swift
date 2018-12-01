//
//  CoordinatorDelegate.swift
//  Builder
//
//  Created by Akshay Bharath on 12/14/17.
//

import RxCocoa
import RxSwift
import UIKit

enum SceneTransitionType {
    case root       // Make controller the root controller
    case push       // Push controller to navigation stack
    case modal      // Present controller modally
}

protocol Scene {
    // The actual controller that is part of the Scene object
    func controller() -> BaseController
}

protocol CoordinatorDelegate: class {
    
    // Init with a window
    init(window: UIWindow)
    
    // Init with a base controller
    init(controller: BaseController)
    
    // Init with a base navigation controller
    init(navigationController: BaseNavigationController)
    
    // TRUE if scene can be popped (or dismissed in the case of modal)
    var canBePopped: BehaviorRelay<Bool> { get }
    
    // Set the current navigation controller
    func setCurrentNavigationController(to controller: BaseNavigationController?)
    
    // Transition modally using specific modal transition style
    @discardableResult
    func transition(to scene: Scene, modalTransitionStyle: UIModalTransitionStyle) -> Completable
    
    // Transition modally using specific modal presentation style
    @discardableResult
    func transition(to scene: Scene, modalPresentationStyle: UIModalPresentationStyle) -> Completable
    
    // Transition to another scene without any custom styles
    @discardableResult
    func transition(to scene: Scene, type: SceneTransitionType) -> Completable
    
    // Pop scene from navigation stack or dismiss current modal
    @discardableResult
    func pop(animated: Bool) -> Completable
    
    func popToRoot(animated: Bool)
}

extension CoordinatorDelegate {
    @discardableResult
    func pop() -> Completable {
        return pop(animated: true)
    }
}
