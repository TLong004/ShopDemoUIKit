

import UIKit

class ReviewCell: UICollectionViewCell {

    @IBOutlet weak var stackView: UIStackView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for (index, view) in stackView.arrangedSubviews.enumerated() {
            view.tag = index + 1
        }
        updateUI(rating: 0)
    }
    
    @IBAction func didTapReview(_ sender: UIButton) {
        let rating = sender.tag
        print("Đánh giá sản phẩm: \(rating)")
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
    
    func setReview() {
        print("Hiện thị thông tin sản phẩm")
    }

}
