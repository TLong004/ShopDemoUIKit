

import UIKit

class MyCartCell: UITableViewCell {

    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var priceProduct: UILabel!
    @IBOutlet weak var nameProduct: UILabel!
    @IBOutlet weak var imageProduct: UIImageView!
    
    var onQuantityChanged: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        quantityTextField.delegate = self
    }
    
    var product: Product?
    
    var quantity: Int = 0 {
        didSet {
            self.quantityTextField.text = "\(self.quantity)"
            self.onQuantityChanged?()
        }
    }
    
    @IBAction func increaseBtn(_ sender: Any) {
        let newQuantity = self.quantity + 1
        CartManager.shared.setQuantity(product: self.product!, quantity: newQuantity)
        self.quantity = newQuantity
    }
    
    @IBAction func reduce(_ sender: Any) {
        if let quantity = Int(self.quantityTextField.text ?? "0"), quantity > 0 {
            let newQuantity = self.quantity - 1
            CartManager.shared.setQuantity(product: self.product!, quantity: newQuantity)
            self.quantity = newQuantity
        }
    }
    
    var removeFromCart: (() -> Void)?

    @IBAction func remove(_ sender: Any) {
        self.removeFromCart?()
    }
    
    func setProduct(_ product: Product, quantity: Int) {
        self.nameProduct.text = product.title
        self.priceProduct.text = "$\(product.price)"
        self.imageProduct.setImage(product.thumbnail)
        self.quantityTextField.text = "\(quantity)"
        self.quantity = quantity
        self.product = product
    }
}
extension MyCartCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let quantily = Int(self.quantityTextField.text!) {
            self.quantity = quantily
            if let product = self.product {
                CartManager.shared.setQuantity(product: product, quantity: self.quantity)
                self.onQuantityChanged?()
            }
            textField.resignFirstResponder()
            return true
        }
        return false
    }
}
