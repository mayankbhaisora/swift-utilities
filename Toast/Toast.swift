import Foundation
import UIKit

class Toast {
    
    enum Theme {
        case warning
        case error
        case info
        case success
        case regular
    }
    
    enum Position {
        case top
        case bottom
    }
    
    // Color Codes
    static let white = UIColor.white
    
    static let error = UIColor(hex: "D8000C")
    static let errorContrast = UIColor(hex: "FFD2D2")
    
    static let warning = UIColor(hex: "9F6000")
    static let warningContrast = UIColor(hex: "FEEFB3")
    
    static let success = UIColor(hex: "4F8A10")
    static let successContrast = UIColor(hex: "DFF2BF")
    
    static let info = UIColor(hex: "17A2B8")
    static let infoContrast = UIColor(hex: "E2F3F9")
    
    private static func makeToast(message: String, controller: UIViewController, type: Theme, duration: Double, position: Position) {
        
        DispatchQueue.main.async {
            var backgroundColor = UIColor.darkGray
            var textColor = white
            
            switch type {
            case .warning:
                textColor = warning
                backgroundColor = warningContrast
            case .error:
                textColor = error
                backgroundColor = errorContrast
            case .info:
                textColor = info
                backgroundColor = infoContrast
            case .success:
                textColor = success
                backgroundColor = successContrast
            default:
                print("default regular")
            }
            
            let toastContainer = UIView(frame: CGRect())
            toastContainer.backgroundColor = backgroundColor
            toastContainer.alpha = 0.0
            toastContainer.layer.cornerRadius = 25;
            toastContainer.clipsToBounds  =  true
            
            let toastLabel = UILabel(frame: CGRect())
            toastLabel.textColor = textColor
            toastLabel.textAlignment = .center;
            toastLabel.font.withSize(12.0)
            toastLabel.text = message
            toastLabel.clipsToBounds  =  true
            toastLabel.numberOfLines = 0
            
            toastContainer.addSubview(toastLabel)
            controller.view.addSubview(toastContainer)
            
            toastLabel.translatesAutoresizingMaskIntoConstraints = false
            toastContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let leadingLabel = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 15)
            let trailingLabel = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -15)
            let bottomLabel = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -15)
            let topLabel = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 15)
            toastContainer.addConstraints([leadingLabel, trailingLabel, bottomLabel, topLabel])
            
            let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: controller.view, attribute: .leading, multiplier: 1, constant: 65)
            let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: controller.view, attribute: .trailing, multiplier: 1, constant: -65)
            
            var c3 = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: controller.view, attribute: .bottom, multiplier: 1, constant: -75)
            if position == .top {
                c3 = NSLayoutConstraint(item: toastContainer, attribute: .top, relatedBy: .equal, toItem: controller.view, attribute: .top, multiplier: 1, constant: 75)
            }
            controller.view.addConstraints([c1, c2, c3])
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
                toastContainer.alpha = 1.0
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
                    toastContainer.alpha = 0.0
                }, completion: {_ in
                    toastContainer.removeFromSuperview()
                })
            })
        }
    }
    
    // static func show(message: String, controller: UIViewController?, type: Theme = .regular, duration: Double = 3, position: Position = .top)
    static func show(message: String, type: Theme = .regular, duration: Double = 3, position: Position = .top, onController controller: UIViewController? = nil) {
        // If the controller is passed when calling the show method
        // Otherwise use the default controller which is on the top
        if let controller = controller {
            makeToast(message: message, controller: controller, type: type, duration: duration, position: position)
        } else {
            // Putting the code in main thread as we are using UIApplication.topViewController
            // Which usages UIApplication.shared.keyWindow?.rootViewController code which must be called from the main thread
            DispatchQueue.main.async {
                if let controller = UIApplication.topViewController {
                    makeToast(message: message, controller: controller, type: type, duration: duration, position: position)
                } else {
                    print("Error showing toast!!!")
                }
            }
        }
    }
}

extension UIApplication {
    
    static var topViewController: UIViewController? {
        
        var currentViewController = UIApplication.shared.keyWindow?.rootViewController
        
        while let presentedViewController = currentViewController?.presentedViewController {
            if let navVc = (presentedViewController as? UINavigationController)?.viewControllers.last {
                currentViewController = navVc
            } else if let tabVc = (presentedViewController as? UITabBarController)?.selectedViewController {
                currentViewController = tabVc
            } else {
                currentViewController = presentedViewController
            }
        }
        return currentViewController
    }
    
    /// This method is used to present viewController from anywhere in the application
    ///
    /// - Parameters:
    ///   - viewController: The view controller to be present
    ///   - showNavigationbar: Bool to decide whether navigation controller needs to be shown or not
    ///   - animated: Flag to decide the animation
    class func present(viewController: UIViewController, andShowNavigationBar showNavigationbar: Bool = false, animated: Bool) {
        // Getting the instance of the top view controller which is currently presenting
        if let topController = UIApplication.topViewController {
            
            if showNavigationbar {
                let navController = UINavigationController(rootViewController: viewController)
                // Persentign the passed viewcontroller with the navigation bar
                topController.present(navController, animated: animated, completion: nil)
            } else {
                // Persentign the passed viewcontroller without the navigation bar
                topController.present(viewController, animated: animated, completion: nil)
            }
        }
    }
}
