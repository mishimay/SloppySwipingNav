import UIKit

public class SloppySwipingNav: UINavigationController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {

    private class SloppySwipingPanGestureRecognizer: UIPanGestureRecognizer {
    }

    class AnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

        private let bottomViewOffset: CGFloat = -60

        var reverse = false
        var linerAnimation = false {
            didSet {
                duration = linerAnimation ? 0.4 : 0.4
            }
        }
        private var duration: NSTimeInterval = 0

        func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
            return duration
        }

        func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
            guard
                let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
                let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
                    return
            }
            let finalFrameForToViewController = transitionContext.finalFrameForViewController(toViewController)
            let containerView = transitionContext.containerView()

            // 移動前のViewを設定
            if !reverse {
                toViewController.view.frame = CGRectOffset(finalFrameForToViewController, fromViewController.view.frame.width, 0)
                addShadow(toViewController)
                containerView?.addSubview(toViewController.view)
            } else {
                addShadow(fromViewController)
                containerView?.insertSubview(toViewController.view, belowSubview: fromViewController.view)

                toViewController.view.frame = CGRectOffset(finalFrameForToViewController, self.bottomViewOffset, 0)
            }

            // 移動させる
            let animations = {
                if !self.reverse {
                    toViewController.view.frame = finalFrameForToViewController
                    fromViewController.view.frame = CGRectOffset(finalFrameForToViewController, self.bottomViewOffset, 0)
                } else {
                    fromViewController.view.frame = CGRectOffset(finalFrameForToViewController, fromViewController.view.frame.width, 0)
                    toViewController.view.frame = finalFrameForToViewController
                }
            }

            // 移動後の処理
            let completion = { (finished: Bool) in
                if !self.reverse {
                    self.removeShadow(toViewController)
                    fromViewController.view.frame = finalFrameForToViewController
                } else {
                    self.removeShadow(fromViewController)
                    fromViewController.view.frame.origin.x = 0
                }

                if transitionContext.transitionWasCancelled() {
                    toViewController.view.removeFromSuperview()
                } else {
                    fromViewController.view.removeFromSuperview()
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            }

            if linerAnimation {
                UIView.animateWithDuration(
                    transitionDuration(transitionContext),
                    delay: 0,
                    options: [.CurveLinear, .AllowUserInteraction],
                    animations: animations,
                    completion: completion
                )
            } else {
                UIView.animateWithDuration(
                    transitionDuration(transitionContext),
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: [.CurveEaseInOut, .AllowUserInteraction],
                    animations: animations,
                    completion: completion
                )
            }
        }

        private func addShadow(viewController: UIViewController) {
            viewController.view.layer.masksToBounds = false
            viewController.view.layer.shadowColor = UIColor.blackColor().CGColor
            viewController.view.layer.shadowRadius = 5
            viewController.view.layer.shadowOpacity = 0.2
        }

        private func removeShadow(viewController: UIViewController) {
            viewController.view.layer.shadowRadius = 0
        }

    }

    class InteractiveTransition: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate {

        private var navigationController: UINavigationController?
        private var shouldCompleteTransition = false
        private(set) var transitionInProgress = false

        func attachToViewController(viewController: UIViewController) {
            navigationController = viewController.navigationController

            let sloppySwipingGestures = viewController.view.gestureRecognizers?.filter { $0 is SloppySwipingPanGestureRecognizer }
            if sloppySwipingGestures == nil || sloppySwipingGestures?.count == 0 {
                let gestureRecognizer = SloppySwipingPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
                gestureRecognizer.delegate = self
                viewController.view.addGestureRecognizer(gestureRecognizer)
            }
        }

        func handlePanGesture(gestureRecognizer: UIPanGestureRecognizer) {
            switch gestureRecognizer.state {
            case .Began:
                transitionInProgress = true
                navigationController?.popViewControllerAnimated(true)

            case .Changed:
                guard let view = gestureRecognizer.view else {
                    break
                }

                let translation = gestureRecognizer.translationInView(view)
                let percent: CGFloat = min(max(translation.x / view.frame.width, 0), 1)

                let velocity = gestureRecognizer.velocityInView(view)
                if velocity.x > 300 {
                    shouldCompleteTransition = true
                } else if velocity.x < -300 {
                    shouldCompleteTransition = false
                } else {
                    shouldCompleteTransition = percent > 0.5
                }

                updateInteractiveTransition(percent)

            case .Cancelled, .Ended:
                transitionInProgress = false
                if !shouldCompleteTransition || gestureRecognizer.state == .Cancelled {
                    cancelInteractiveTransition()
                } else {
                    finishInteractiveTransition()
                }

            default:
                break
            }
        }

        func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard
                let view = gestureRecognizer.view,
                let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
                    return false
            }

            let translation = gestureRecognizer.translationInView(view)
            return fabs(translation.x) >= fabs(translation.y)
        }

    }

    private let animatedTransitioning = AnimatedTransitioning()
    private let interactiveTransition = InteractiveTransition()

    public override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
    }

    public func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {

        if viewController != viewControllers.first { // Exclude root viewController
            interactiveTransition.attachToViewController(viewController)
        }
    }

    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        animatedTransitioning.reverse = operation == .Pop
        return animatedTransitioning
    }

    public func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        animatedTransitioning.linerAnimation = interactiveTransition.transitionInProgress
        return interactiveTransition.transitionInProgress ? interactiveTransition : nil
    }

}
