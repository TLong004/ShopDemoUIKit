

import UIKit

protocol ReviewCellDelegate: AnyObject {
    func didTapMedia()
}

class ReviewCell: UICollectionViewCell {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var content: UITextView!
    
    weak var delegate: ReviewCellDelegate?
    
    @IBAction func tapMedia(_ sender: Any) {
        delegate?.didTapMedia()
    }
    var review: UserReview?
    var imagesReview: [String] = []
    
    @IBAction func tapSave(_ sender: Any) {
        if let currentReview = review {
            var updatedReview = currentReview
            updatedReview.content = content.text ?? ""
            print(self.imagesReview)
            updatedReview.images = self.imagesReview
            
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            updatedReview.createdAt = formatter.string(from: now)
            
            ReviewManager.shared.addReview(userReview: updatedReview)
            let user = ReviewManager.shared.loadReview(forProductId: review!.productId)
            print("Lưu review thành công")
            print(user)
        } else {
            print("Lỗi")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for (index, view) in stackView.arrangedSubviews.enumerated() {
            view.tag = index + 1
        }
        updateUI(rating: 0)
    }
    
    @IBAction func didTapReview(_ sender: UIButton) {
        let rating = sender.tag
        review?.rating = rating
        updateUI(rating: rating)
    }
    
    func updateUI(rating: Int) {
        for (index, view) in stackView.arrangedSubviews.enumerated() {
            let btn = view as! UIButton
            if index < rating {
                btn.tintColor = .systemYellow
            } else {
                btn.tintColor = .systemGray4
            }
        }
    }
    
    func setReview(productId: Int) {
        if review == nil {
            review = UserReview(productId: productId, rating: 0, content: "", images: [], createdAt: "")
        } else {
            review?.productId = productId
        }
    }

}
