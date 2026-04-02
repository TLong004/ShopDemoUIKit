

import UIKit


protocol ReviewCellDelegate: AnyObject {
    func didTapMedia()
    func didUpdateImages(images: [UIImage])
}

class ReviewCell: UICollectionViewCell {
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var content: UITextView!
    weak var delegate: ReviewCellDelegate?
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedImages: [UIImage] = [] {
        didSet {
            self.collectionView.reloadData()
            
            DispatchQueue.main.async {
                let contentHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height
                self.collectionViewHeightConstraint.constant = contentHeight
                self.layoutIfNeeded()
                self.delegate?.didUpdateImages(images: self.selectedImages)
            }
        }
    }
    
    var imagesRV: [String] = []
    
    var review: UserReview?
    
    @IBAction func tapSave(_ sender: Any) {
        if let currentReview = review {
            var updatedReview = currentReview
            updatedReview.content = content.text ?? ""
            
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            updatedReview.createdAt = formatter.string(from: now)
            for image in selectedImages {
                imagesRV.append(ReviewManager.shared.saveImageToDisk(image: image)!)
            }
            updatedReview.images = imagesRV
            ReviewManager.shared.addReview(userReview: updatedReview)
            print("Lưu review thành công")
            self.imagesRV = []
            self.selectedImages = []
            self.delegate?.didUpdateImages(images: [])
            
            guard let user = ReviewManager.shared.loadReview(forProductId: updatedReview.productId) else {
                print("Không tìm thấy review cho id")
                return
            }
            print("Dữ liệu tìm thấy: \(user)")
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
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.collectionViewLayout = createLayout()
        self.collectionView.register(UINib(nibName: "ButtonImageCell", bundle: nil), forCellWithReuseIdentifier: "ButtonImageCell")
        self.collectionView.register(UINib(nibName: "ImageReviewCell", bundle: nil), forCellWithReuseIdentifier: "ImageReviewCell")
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
    
    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, _ in
            
            let width = self.selectedImages.isEmpty ? 1.0 : 0.25
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(width),
                                                  heightDimension: .fractionalWidth(0.25))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(100))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .none
            return section
        }
    }
}

extension ReviewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < selectedImages.count {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageReviewCell", for: indexPath) as? ImageReviewCell else {
                return UICollectionViewCell()
            }
            cell.setImage(selectedImages[indexPath.row])
            cell.delegate = self
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonImageCell", for: indexPath) as? ButtonImageCell else {
                return UICollectionViewCell()
            }
            cell.confige(check: self.selectedImages.count == 0)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == selectedImages.count {
            delegate?.didTapMedia()
        }
    }
}
extension ReviewCell: ImageReviewCellDelegate {
    func didDeleteImage(cell: ImageReviewCell) {
        guard let index = collectionView.indexPath(for: cell)?.row else { return }
        selectedImages.remove(at: index)
        delegate?.didUpdateImages(images: selectedImages)
        collectionView.reloadData()
    }
}
