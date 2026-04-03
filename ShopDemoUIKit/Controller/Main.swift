

import UIKit

class Main: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadge), name: NSNotification.Name("cartUpdate"), object: nil)
    }
    
    @objc func updateBadge() {
        if let tab = self.viewControllers?[1] {
            let count = CartManager.shared.totalItems
            tab.tabBarItem.badgeValue = count == 0 ? nil : "\(count)"
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        CartManager.shared.totalItems = 0
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if let nav = viewController as? UINavigationController {
            nav.popToRootViewController(animated: false)
        }
        return true
    }
    

}
