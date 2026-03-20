
import UIKit

enum SectionTypeDatail: Int, CaseIterable {
    case banner = 0
    case categoryImage = 1
    case productDetail = 2
}

class DetailViewController: UIViewController {
   
    @IBOutlet weak var btnBuyNow: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnAddTopCart: UIButton!

    var product: Product!
    var images: [String] = []
    var banner: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Shop Demo"
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createLayout()
        images = product?.images ?? []
        banner = product?.thumbnail ?? images[0]
        let bannerSection = IndexSet(integer: SectionTypeDatail.banner.rawValue)
        collectionView.reloadSections(bannerSection)
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
            }
        }
    }
    
    func createBannerLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(200)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        return section
    }
    
    func createDetailImagesLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.3), heightDimension: .absolute(80)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        return section
    }
    
    func createProductLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(350)), subitems: [item])
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
        return SectionTypeDatail.allCases.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1 {
            return self.images.count
        } else if section == 2 {
            return 1
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailBanner", for: indexPath) as? DetailBanner else {
                return UICollectionViewCell()
            }
            cell.setImage(self.banner)
            return cell
        } else if indexPath.section == 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailImage", for: indexPath) as? DetailImageProductCell else {
                return UICollectionViewCell()
            }
            cell.setImage(images[indexPath.row])
            cell.delegate = self
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailProduct", for: indexPath) as? DetailProduct else {
                return UICollectionViewCell()
            }
            if let productData = self.product {
                cell.config(product: productData)
            }
            return cell
        }
    }
    
    
}
