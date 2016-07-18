//
//  TranscriptRouter.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public class TranscriptRouter: NSObject {
    
    private let parentVC: UIViewController
    private let moduleVC: TranscriptVC
    
    private let transitionManager = TranscriptTransitionManager()
    
    init(forPresenting controller: TranscriptVC, in parentVC: UIViewController) {
        self.parentVC = parentVC
        self.moduleVC = controller
        
        controller.modalPresentationStyle = .Custom
        controller.transitioningDelegate = transitionManager

    }

    
    public func show(from sourceView: UIView, completion: (Bool -> Void)?) {
        
        let thumbView = moduleVC.contentView.thumbHolder
        
        let originalVCBackground = moduleVC.view.backgroundColor
        
        thumbView.alpha = 0;
        moduleVC.view.backgroundColor = UIColor.clearColor()
        
        let navigationBar = moduleVC.contentView.navigationBar
        
        let completion = {
            
            let navbarTranslate = CGAffineTransformMakeTranslation(0, -navigationBar.bounds.size.height)
            
            navigationBar.transform = navbarTranslate
            
            let sourceAbsolutePoint = sourceView.convertPoint(CGPoint.zero, toView: nil)
            let destinationAbsolutePoint = thumbView.convertPoint(CGPoint.zero, toView: nil)
            
            let thumbTranslate =
                CGAffineTransformMakeTranslation(sourceAbsolutePoint.x - destinationAbsolutePoint.x,
                                                 sourceAbsolutePoint.y - destinationAbsolutePoint.y)
            
            thumbView.transform = thumbTranslate
            
            thumbView.alpha = 1;
            
            let animations = {
            
                thumbView.transform = CGAffineTransformIdentity
                
                navigationBar.transform = CGAffineTransformIdentity
                
                self.moduleVC.view.backgroundColor = originalVCBackground
            }
            
            UIView.animateWithDuration(0.6, delay: 0, options: [], animations: animations, completion: completion)
            self.addDismissGestureRecognizerTo(viewController: self.moduleVC)

            

        }
        
        parentVC.presentViewController(moduleVC,
                                       animated: false,
                                       completion:completion)
        
    }
    
    public func hide() {
        moduleVC.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    private func addDismissGestureRecognizerTo(viewController controller: UIViewController) {
                
        let recognizer = UIPanGestureRecognizer(target: self,
                                                action: #selector(self.handleDismissRecognizer))
        
        recognizer.delegate = self
        
        controller.view.addGestureRecognizer(recognizer)
    }
    
    var previousProgress = CGFloat(0)
    var progress = CGFloat(0)
    
    @objc func handleDismissRecognizer(recognizer: UIPanGestureRecognizer) {
        
        let interactor = self.transitionManager.interactive

        guard let view = recognizer.view else {
            return
        }
                
        switch recognizer.state {
            
        case .Began:
            hide()
            moduleVC.output?.didStartInteractiveDismissal()
            
        case .Changed:
            
            if previousProgress != progress {
                previousProgress = progress
            }
        
            let translation = recognizer.translationInView(view)
            let verticalMovement = translation.y / view.bounds.height
            let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
            let downwardMovementPercent = fminf(downwardMovement, 1.0)
            progress = CGFloat(downwardMovementPercent)
            
            interactor.updateInteractiveTransition(progress)
            
        case .Cancelled:
            interactor.cancelInteractiveTransition()
            moduleVC.output?.didCancelInteractiveDismissal()
            
        case .Ended:
            if previousProgress > progress {
                interactor.cancelInteractiveTransition()
                moduleVC.output?.didCancelInteractiveDismissal()
            }
            else {
                interactor.finishInteractiveTransition()
            }
            
        default:
            break
        }
    }
}


class TranscriptTransitionManager: NSObject, UIViewControllerTransitioningDelegate {
    
    let interactive = UIPercentDrivenInteractiveTransition()
    let animated = TranscriptTransitioning()

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animated
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactive
    }
}

class TranscriptTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
 
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    @objc func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1
    }
    
    // This is a convenience and if implemented will be invoked by the system when the transition context's completeTransition: method is invoked.
    @objc func animateTransition(context: UIViewControllerContextTransitioning) {
        
        guard
            let toController = context.viewControllerForKey(UITransitionContextFromViewControllerKey)
            else {
                return
        }
        
        let height = CGFloat((context.containerView()?.bounds.size.height)!)
        
        let duration = transitionDuration(context)
        
        UIView.animateWithDuration(duration, animations: { 
            
            toController.view.frame = CGRect(origin: CGPoint(x: 0, y: height), size: toController.view.frame.size)
            
            }) { (completed) in
                context.completeTransition(!context.transitionWasCancelled())
        }
        
    }
    
    @objc func animationEnded(transitionCompleted: Bool) {
        
    }    
}

extension TranscriptRouter: UIGestureRecognizerDelegate {

    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        
        let velocity = gestureRecognizer.velocityInView(self.moduleVC.view)
        return fabs(velocity.y) > fabs(velocity.x)
    }
}