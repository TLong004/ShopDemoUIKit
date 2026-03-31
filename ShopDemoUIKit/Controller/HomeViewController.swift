
import UIKit

enum SectionType: Int, CaseIterable {
    case banner = 0
    case category = 1
    case product = 2
    
    var identifier: String {
        switch self {
        case .banner: return "BannerCell"
        case .category: return "CategoryCell"
        case .product: return "MyProductCell"
        }
    }
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var search: UITextField!
    
    var banners: [Product] = []
    var categories: [Category] = []
    var products: [Product] = []
    var phanLoai = ""
    var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createLayout()
        search.delegate = self
        let nib = UINib(nibName: "MyProductCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "MyProductCell")
        Task {
            await fetchProducts(isInitialLoad: true)
        }
    }
    
    @MainActor
    func fetchProducts(isInitialLoad: Bool = false) async {
        do {
            if isInitialLoad {
                async let reponse: ProductResponse = NetworkManager.shared.request(urlString: API.banner)
                async let categories: [Category] = NetworkManager.shared.request(urlString: API.category)
                let (bannersRep, categoriesRep) = try await (reponse, categories)
                banners = bannersRep.products
                self.categories = categoriesRep
                let cat = Category(slug: "", name: "All", url: "")
                self.categories.insert(cat, at: 0)
                collectionView.reloadData()
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
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.565)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        return section
    }
    
    func createCategoryLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .fractionalHeight(1.0)))
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let height: CGFloat = isPad ? 60 : 30
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .absolute(height)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        return section
    }
    
    func createProductLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let width = isPad ? 0.2 : 0.36
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(width)), subitems: [item])
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
        if let index = self.categories.firstIndex(where: {$0.slug == category}) {
            let indexPath = IndexPath(item: index, section: SectionType.category.rawValue)
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
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
        guard let section = SectionType(rawValue: indexPath.section) else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: section.identifier, for: indexPath)
        switch section {
        case .banner:
            (cell as? BannerCell)?.setImage(banners[indexPath.row].thumbnail)
        case .category:
            let cat = categories[indexPath.row]
            (cell as? CategoryCell)?.setButtonTitle(cat.name, slug: cat.slug)
            (cell as? CategoryCell)?.delegate = self
        case .product:
            let product = products[indexPath.row]
            (cell as? ProductCell)?.setProduct(product)
            (cell as? ProductCell)?.delegate = self
            (cell as? ProductCell)?.addButton = {
                CartManager.shared.addToCart(product: product)
                CartManager.shared.showToast(message: "Đã thêm vào giỏ hàng", view: self.view)
            }
        }
        return cell
    }
}

extension HomeViewController: UITextFieldDelegate, ProductCellDelegate {
    func didSelectProduct(_ product: Product) {
        let storyBoard = UIStoryboard(name: "DetailProduct", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "DetailProduct") as! DetailViewController
        vc.product = product
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let storyBoard = UIStoryboard(name: "Search", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "searchVC") as! SearchViewController
        self.navigationController?.pushViewController(vc, animated: true)
        return false
    }
}
