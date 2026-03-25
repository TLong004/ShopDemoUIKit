
import UIKit
import Kingfisher

class BannerCell: UICollectionViewCell {
    @IBOutlet weak var bannerImage: UIImageView!
    
    func setImage(_ imageUrl: String){
        bannerImage.setImage(imageUrl)
    }
}
