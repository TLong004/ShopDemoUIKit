
import UIKit

enum SectionTypeDatail: Int, CaseIterable {
    case banner = 0
    case categoryImage = 1
    case productDetail = 2
    case review = 3
    case myReview = 4
    
    var Identifier: String {
        switch self {
        case .banner: return "DetailBanner"
        case .categoryImage: return "DetailImage"
        case .productDetail: return "DetailProduct"
        case .review: return "ReviewCell"
        case .myReview: return "MyReviewCell"
        }
    }
}

class DetailViewController: UIViewController {
   
    @IBOutlet weak var btnBuyNow: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnAddTopCart: UIButton!

    var product: Product!
    @IBAction func addToCart(_ sender: Any) {
        CartManager.shared.addToCart(product: product)
        CartManager.shared.showToast(message: "Đã thêm vào giỏ hàng", view: self.view)
    }
    
    var images: [String] = []
    var banner: String = ""
    var imagesRV: [UIImage] = []
    var draftRating: Int = 0
    var draftContent: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Shop Demo"
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createLayout()
        images = product?.images ?? []
        banner = product?.thumbnail ?? images[0]
        let bannerSection = IndexSet(integer: SectionTypeDatail.banner.rawValue)
        collectionView.reloadSections(bannerSection)
        collectionView.register(UINib(nibName: "ReviewCell", bundle: nil), forCellWithReuseIdentifier: SectionTypeDatail.review.Identifier)
        collectionView.register(UINib(nibName: "MyReviewCell", bundle: nil), forCellWithReuseIdentifier: SectionTypeDatail.myReview.Identifier)

    }
    
   
    
    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout {
            sectionIndex, _ in guard let sectionType = SectionTypeDatail(rawValue: sectionIndex) else { fatalError() }
            switch sectionType {
            case .banner:
                return self.createBannerLayout()
            case .categoryImage:
                return self.createDetailImagesLayout()
            case .productDetail:
                return self.createProductLayout()
            case .review:
                return self.createProductLayout()
            case .myReview:
                return self.createProductLayout()
            }
        }
    }
    
    func createBannerLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.444)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        return section
    }
    
    func createDetailImagesLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(0.3*0.5)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        return section
    }
    
    func createProductLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }


}
extension DetailViewController: UICollectionViewDataSource, tapImageProductDelegate {
    func didSelectImage(image: String) {
        banner = image
        let bannerSection = IndexSet(integer: SectionTypeDatail.banner.rawValue)
        collectionView.reloadSections(bannerSection)
        
        if let index = images.firstIndex(of: image) {
            let indexPath = IndexPath(row: index, section: SectionTypeDatail.categoryImage.rawValue)
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let isBought = CartManager.shared.isChecout(product: self.product)
        let isReview = ReviewManager.shared.isReview(product: self.product)
        if !isBought {
            return isReview ? SectionTypeDatail.allCases.count - 1 : SectionTypeDatail.allCases.count - 2
        }
        return SectionTypeDatail.allCases.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = SectionTypeDatail(rawValue: section) else { return 0 }
        switch sectionType {
        case .categoryImage:
            return self.images.count
        case .review:
            return CartManager.shared.isChecout(product: product) && !ReviewManager.shared.isReview(product: product) ? 1 : 0
        case .myReview:
            return ReviewManager.shared.isReview(product: self.product) ? 1 : 0
        default:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = SectionTypeDatail(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: section.Identifier, for: indexPath)
        switch section {
        case .banner:
            (cell as? DetailBanner)?.setImage(self.banner)
        case .categoryImage:
            (cell as? DetailImageProductCell)?.setImage(images[indexPath.row])
            (cell as? DetailImageProductCell)?.delegate = self
        case .productDetail:
            if let productData = self.product {
                (cell as? DetailProduct)?.config(product: productData)
            }
        case .review:
            (cell as? ReviewCell)?.delegate = self
            (cell as? ReviewCell)?.rating = self.draftRating
            (cell as? ReviewCell)?.updateUI(rating: self.draftRating)
            (cell as? ReviewCell)?.content.text = self.draftContent
            (cell as? ReviewCell)?.selectedImages = self.imagesRV
            (cell as? ReviewCell)?.setReview(productId: self.product!.id)
        case .myReview:
            (cell as? MyReviewCell)?.config(product: self.product)
        }
        return cell
    }
}

extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, ReviewCellDelegate {
    func didUpdateReviewData(content: String, rating: Int) {
        self.draftRating = rating
        self.draftContent = content
    }
    
    func didUpdateImages(images: [UIImage]) {
        self.imagesRV = images
        UIView.performWithoutAnimation {
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
        if ReviewManager.shared.isReview(product: product) {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func didTapMedia() {
        let popup = CustomPopupViewController()
        
        popup.modalTransitionStyle = .crossDissolve
        popup.modalPresentationStyle = .overCurrentContext
        
        popup.onSelectSource = { [weak self] source in
            self?.presentPicker(source: source)
        }
        
        present(popup, animated: true, completion: nil)
    }
    
    func presentPicker(source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = source
        picker.allowsEditing = true
        picker.mediaTypes = ["public.image", "public.movie"]
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let image = info[.editedImage] as? UIImage {
                print("Đã lấy được ảnh \(image)")
                self.imagesRV.append(image)
                let section = IndexSet(integer: SectionTypeDatail.review.rawValue)
                self.collectionView.reloadSections(section)
            } else if let video = info[.mediaURL] as? URL {
                print("Đã lấy được video \(video)")
            }
        }
    }
    
}
