/*
 Copyright 2018 Joseph Quigley
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

@objc protocol PopsViewController: class {
    var animatePop: Bool { get set }
    
    /// If the view controller containing this object is in a `UINavigationController` which is presented modally, dismiss the modal in-lieu of popping the navigation controller.
    var dismissNavigationController: Bool { get set }
    
    
    /// Called when the modal is dismissed or the navigation stack pop is complete.
    var popCompletionCallback: (()->Void)? { get set }
    
    
    /// If the view controller containing this object is in a `UINavigationController` and you want to pop to a particular view controller, specify that controller here.
    var popDestiniation: UIViewController? { get set }
    
    /// Closure that will be called when the button is tapped. Call the closure provided as an argument to initiate the pop. Ignore it if pop is not desired.
    var prePopHook: (@escaping ()->Void)->Void { get set }
    
    @objc func tryPopController()
}

extension PopsViewController {
    func setup() {
        if let button = self as? UIButton {
            button.addTarget(self, action: #selector(tryPopController), for: .touchUpInside)
        }
        if let barButton = self as? UIBarButtonItem {
            barButton.action = #selector(tryPopController)
        }
    }
    
    func popViewController() {
        let vc: UIViewController
        
        if let responder = self as? UIResponder,
            let viewController = getViewController(responder: responder) {
            vc = viewController
        }
        else if let barButton = self as? PopViewControllerBarButton,
            let frontVC = topViewController(window: barButton.window) {
            vc = frontVC
        }
        else {
            print("Unable to pop/dismiss this view controller because the class conforming to \(String(describing: type(of: self))) is not a \(String(describing: UIResponder.self)) or a \(String(describing: PopViewControllerBarButton.self))")
            return
        }
        
        let modalWithNav = vc.presentingViewController != nil &&
            vc.navigationController != nil
        
        //Decide what to do with both a modal and a navigation controller
        if (modalWithNav && dismissNavigationController) || vc.navigationController == nil {
            vc.dismiss(animated: animatePop, completion: popCompletionCallback)
            return
        }
        
        guard let popDestination = popDestiniation else {
            vc.navigationController?.popViewController(animated: animatePop)
            return
        }
        vc.navigationController?.popToViewController(popDestination,
                                                     animated: animatePop)
        
    }
    
    private func getViewController(responder: UIResponder) -> UIViewController? {
        if let vc = responder as? UIViewController {
            return vc
        }
        
        if let next = responder.next {
            return getViewController(responder: next)
        }
        
        return nil
    }
    
    private func topViewController(window: UIWindow? = nil) -> UIViewController? {
        var top = (window ?? UIApplication.shared.keyWindow)?.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
}

extension PopViewControllerBarButton {
    func tryPopController() {
        prePopHook(popViewController)
    }
}

extension PopViewControllerButton {
    func tryPopController() {
        prePopHook(popViewController)
    }
}
