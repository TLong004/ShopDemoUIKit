
import UIKit
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
        let cacheKey = NSString(string: product.thumbnail)
        if let imageCache = ImageCache.shared.object(forKey: cacheKey) {
            print("Đã lấy ảnh product từ cache")
            self.image.image = imageCache
            return
        }
        Task{
            do {
                guard let url = URL(string: product.thumbnail) else {return}
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let imageCache = UIImage(data: data) else {return}
                ImageCache.shared.setObject(imageCache, forKey: cacheKey)
                print("Đã lưu ảnh product vào cache")
                self.image.image = imageCache
            } catch {
                print("Lỗi tải ảnh")
            }
            
        }
    }
    
    @objc func handleTap(){
        delegate?.didSelectProduct(product)
    }
}
