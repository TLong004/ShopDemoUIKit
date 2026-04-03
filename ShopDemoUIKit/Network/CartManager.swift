

import Foundation
import UIKit

class CartManager {
    static let shared = CartManager()
    var totalItems: Int {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name("cartUpdate"), object: nil)
        }
    }
    private init() {
        self.totalItems = 0
        products = self.loadCart(key: self.cartKey)
        total = products.reduce(0) { $0 + Double($1.quantity) * $1.product.price }
    }
    
    var products: [CartItem] = []
    var total: Double = 0.0
    private let cartKey = "user_cart_items"
    private let cartKeyCheckout = "items_checkout"
    
    func addToCart(product: Product) {
        if let item = products.firstIndex(where: { $0.product.id == product.id }) {
            products[item].quantity += 1
        } else {
            products.append(CartItem(product: product, quantity: 1, isCheckedOut: false))
        }
        total += product.price
        self.totalItems += 1
        self.saveCart(items: products, key: self.cartKey)
    }
    
    func removeFromCart(product: Product) {
        if let item = products.firstIndex(where: {$0.product.id == product.id}) {
            total -= product.price * Double(products[item].quantity)
            products.remove(at: item)
        }
        self.saveCart(items: products, key: self.cartKey)
    }
    
    func setQuantity(product: Product, quantity: Int) {
        if let item = products.firstIndex(where: {$0.product.id == product.id}) {
            products[item].quantity = quantity
        }
        total = products.reduce(0) { $0 + Double($1.quantity) * $1.product.price }
        self.saveCart(items: products, key: self.cartKey)
    }
    
    func getTotal() -> Double {
        return total
    }
    
    func saveCart(items: [CartItem], key: String) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(items)
            UserDefaults.standard.set(data, forKey: key)
            print("Lưu thành công \(items.count) vào bộ nhớ")
        } catch {
            print("Lỗi khi lưu \(error.localizedDescription)")
        }
    }
    
    func loadCart(key: String) -> [CartItem] {
        guard let savedData = UserDefaults.standard.data(forKey: key) else { return [] }
        let decoder = JSONDecoder()
        do {
            let data = try decoder.decode([CartItem].self, from: savedData)
            print("Load dữ liệu thành công")
            return data
        } catch {
            print("Lỗi khi load dữ liệu \(error.localizedDescription)")
            return []
        }
    }
        
    func setCheckOut() {
        let tmp = loadCart(key: self.cartKeyCheckout)
        var items = self.products + tmp
        for i in 0..<items.count {
            items[i].setCheckOut()
        }
        saveCart(items: items, key: self.cartKeyCheckout)
    }
    
    func isChecout(product: Product) -> Bool {
        let items = loadCart(key: self.cartKeyCheckout)
        if items.contains(where: {$0.product.id == product.id}) {
            return true
        }
        return false
    }
    
    func showToast(message: String, view: UIView) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 100, y: view.frame.size.height-150, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 1.5, delay: 0.3, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
