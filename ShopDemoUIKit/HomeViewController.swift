
import UIKit

enum SectionType: Int, CaseIterable {
    case banner = 0
    case category = 1
    case product = 2
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var search: UITextField!
    
    var banners: [Product] = []
    var categories: [Category] = []
    var products: [Product] = []
    var phanLoai = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createLayout()
        search.delegate = self
        Task {
            await fetchProducts(isInitialLoad: true)
        }
    }
    
    @MainActor
    func fetchProducts(isInitialLoad: Bool = false) async {
        do {
            if isInitialLoad {
                let reponse: ProductResponse = try await NetworkManager.shared.request(urlString: API.banner)
                let categoriesRep: [Category] = try await NetworkManager.shared.request(urlString: API.category)
                banners = reponse.products
                categories = categoriesRep
                let cat = Category(slug: "", name: "All", url: "")
                categories.insert(cat, at: 0)
                collectionView.reloadData()
                
                print(categories)
            }
            let url = phanLoai == "" ? API.products : API.products + "/category/\(phanLoai)"
            let data: DataProduct = try await NetworkManager.shared.request(urlString: url)
            products = data.products
            let productSection = IndexSet(integer: SectionType.product.rawValue)
            collectionView.reloadSections(productSection)
 
        } catch {
            print(error)
        }
    }
    
    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout {
            sectionIndex, _ in guard let sectionType = SectionType(rawValue: sectionIndex) else { fatalError() }
            switch sectionType {
            case .banner:
                return self.createBannerLayout()
            case .category:
                return self.createCategoryLayout()
            case .product:
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
    
    func createCategoryLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .absolute(30)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        section.orthogonalScrollingBehavior = .continuous
        return section
    }
    
    func createProductLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, CategoryCellDelegate {
    func didTapCategoryCell(_ category: String) {
        phanLoai = category
        Task {
            await fetchProducts()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return SectionType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return banners.count
        } else if section == 1{
            return categories.count
        } else {
            return products.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: indexPath) as! BannerCell
            cell.setImage(banners[indexPath.row].thumbnail)
            return cell
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            let category = categories[indexPath.row]
            let slug = category.slug
            cell.setButtonTitle(category.name, slug: slug)
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
            let product = products[indexPath.row]
            cell.setProduct(product)
            return cell
        }
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "searchVC") as! SearchViewController
        self.navigationController?.pushViewController(vc, animated: true)
        return false
    }
}
