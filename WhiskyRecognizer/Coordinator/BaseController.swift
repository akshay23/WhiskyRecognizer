//
//  BaseController.swift
//  Builder
//
//  Created by Akshay Bharath on 1/4/18.
//

import RxSwift
import UIKit

protocol BaseController: class {
    var naviController: BaseNavigationController? { get }
    var presentingController: BaseController? { get }
    
    func present(controller: BaseController, animated flag: Bool, completion: (() -> Swift.Void)?)
    func dismissController(animated flag: Bool, completion: (() -> Swift.Void)?)
}

extension BaseController where Self: UIViewController {
    func present(controller: BaseController, animated flag: Bool, completion: (() -> Swift.Void)?) {
        guard let viewController = controller as? UIViewController else { return }
        present(viewController, animated: flag, completion: completion)
    }
    
    func dismissController(animated flag: Bool = true, completion: (() -> Swift.Void)? = nil) {
        dismiss(animated: flag, completion: completion)
    }
}

extension UIViewController: BaseController {
    var naviController: BaseNavigationController? { return self.navigationController }
    var presentingController: BaseController? { return self.presentingViewController }
}

protocol BaseNavigationController {
    var visibleController: BaseController? { get }
    var controllers: [BaseController] { get }
    var childControllers: [BaseController] { get }
    
    func pushController(controller: BaseController, animated: Bool)
    func popController(animated: Bool) -> BaseController?
}

extension BaseNavigationController where Self: UINavigationController {
    func pushController(controller: BaseController, animated: Bool) {
        guard let viewController = controller as? UIViewController else { return }
        pushViewController(viewController, animated: animated)
    }
    
    func popController(animated: Bool) -> BaseController? {
        return popViewController(animated: animated)
    }
}

extension UINavigationController: BaseNavigationController {
    var visibleController: BaseController? { return self.visibleViewController }
    var controllers: [BaseController] { return self.viewControllers }
    var childControllers: [BaseController] { return self.childViewControllers }
}
