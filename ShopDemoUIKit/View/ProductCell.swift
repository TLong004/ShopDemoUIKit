
import UIKit
import Kingfisher

protocol ProductCellDelegate: AnyObject {
    func didSelectProduct(_ product: Product)
}
class ProductCell: UICollectionViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var rating: UILabel!

    var product: Product!
    weak var delegate: ProductCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        name.addGestureRecognizer(tap)
    }
    
    func setProduct(_ product: Product) {
        self.product = product
        self.name.text = product.title
        self.price.text = "$\(product.price)"
        let tmp = product.rating.rounded()
        var rating = ""
        switch tmp {
        case 0: rating = ""
        case 1: rating = "⭐️"
        case 2: rating = "⭐️⭐️"
        case 3: rating = "⭐️⭐️⭐️"
        case 4: rating = "⭐️⭐️⭐️⭐️"
        case 5: rating = "⭐️⭐️⭐️⭐️⭐️"
        default: rating = ""
        }
        self.rating.text = rating + " \(product.rating)"
        self.image.setImage(product.thumbnail)
    }
    
    @objc func handleTap(){
        delegate?.didSelectProduct(product)
    }
}
