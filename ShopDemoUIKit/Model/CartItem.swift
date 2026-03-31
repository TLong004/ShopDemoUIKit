

import Foundation

struct CartItem: Codable {
    let product: Product
    var quantity: Int
    var isCheckedOut: Bool
    
    init(product: Product, quantity: Int, isCheckedOut: Bool) {
        self.product = product
        self.quantity = quantity
        self.isCheckedOut = isCheckedOut
    }
    
    mutating func setCheckOut() {
        if !isCheckedOut {
            isCheckedOut = true
        }
    }
}
