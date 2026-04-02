
import UIKit

class MyReviewCell: UICollectionViewCell {
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var reatingStack: UIStackView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images: [UIImage] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for (index, view) in reatingStack.arrangedSubviews.enumerated() {
            view.tag = index + 1
        }
        collectionView.register(UINib(nibName: "MyImageReviewCell", bundle: nil), forCellWithReuseIdentifier: "MyImageReviewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = self.createLayout()
        
    }
    
    func config(product: Product) {
        self.images = []
        
        let userReview = ReviewManager.shared.loadReview(forProductId: product.id)
        textView.text = userReview?.content
        
        let rating = userReview?.rating ?? 0
        print(rating)
        for view in reatingStack.arrangedSubviews {
            view.tintColor = (view.tag <= rating) ? .systemYellow : .systemGray4
        }
        
        if let imagesData = userReview?.images {
            for fileName in imagesData {
                if let diskImage = ReviewManager.shared.loadImageFromDisk(fileName: fileName) {
                    self.images.append(diskImage)
                }
            }
        }
        
        self.collectionView.reloadData()
        
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.layoutIfNeeded()
        
        let contentHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height
        self.collectionViewHeightConstraint.constant = contentHeight
        
        self.collectionView.isHidden = images.isEmpty
        
        self.layoutIfNeeded()
    }
    
    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25),
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

extension MyReviewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyImageReviewCell", for: indexPath) as! MyImageReviewCell
        cell.setImage(images[indexPath.row])
        return cell
    }
}
