/*
 Copyright 2018 Joseph Quigley
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

/// UIBarButton subclass that can be set in InterfaceBuilder or in code to automatically dismiss a modal, or pop a view controller when tapped. Also takes into consideration modals with navigation controllers, and provides a pre-pop/dismiss hook in case conditionally popping the view controller is desired.
class PopViewControllerBarButton: UIBarButtonItem, PopsViewController {
    @IBInspectable var animatePop: Bool = true
    
    /// If the view controller containing this bar button item is in a `UINavigationController` which is presented modally, dismiss the modal in-lieu of popping the navigation controller.
    @IBInspectable var dismissNavigationController: Bool = false
    
    
    /// Called when the modal is dismissed or the navigation stack pop is complete.
    var popCompletionCallback: (()->Void)?
    
    /// If the view controller containing this object is in a `UINavigationController` and you want to pop to a particular view controller, specify that controller here.
    weak var popDestiniation: UIViewController?
    
    /// Closure that will be called when the button is tapped. Call the closure provided as an argument to initiate the pop. Ignore it if pop is not desired.
    var prePopHook: (@escaping ()->Void)->Void = { callback in
        callback()
    }
    
    /// Explicitly associate this bar button item with a particular UIWindow. Leave nil to default to the UIApplication's keyWindow.
    var window: UIWindow?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init() {
        super.init()
        setup()
    }
}
