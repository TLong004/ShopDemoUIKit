
import UIKit
import Kingfisher

protocol tapImageProductDelegate: AnyObject {
    func didSelectImage(image: String)
}
class DetailImageProductCell: UICollectionViewCell {
    @IBOutlet weak var detailImage: UIImageView!
    weak var delegate: tapImageProductDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.detailImage.addGestureRecognizer(tapGesture)
        self.detailImage.isUserInteractionEnabled = true
    }
    
    var imageUrl: String!
    
    func setImage(_ imageUrl: String){
        self.imageUrl = imageUrl
        detailImage.setImage(imageUrl)
    }
    
    override var isSelected: Bool {
        didSet {
            detailImage.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
            detailImage.backgroundColor = isSelected ? .systemBlue.withAlphaComponent(0.1) : .systemGray6
        }
    }
    
    @objc func handleTapGesture() {
        guard let url = imageUrl else { return }
        delegate?.didSelectImage(image: url)
    }
}
