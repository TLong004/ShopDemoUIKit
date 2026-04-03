//
//  SearchViewControlelr.swift
//  ShopDemoUIKit
//
//  Created by gem on 19/3/26.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var search: UITextField!
    
    var products: [Product] = []
    var searchTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "MyProductCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "MyProductCell")
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createLayout()
        search.becomeFirstResponder()
    }

    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout {_,_ in 
            return self.createProductLayout()
        }
    }
    
    func createProductLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let width = isPad ? 0.2 : 0.36
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(width)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    @MainActor
    func performSearch(query: String) async {
        do {
            let url = API.search + query
            let data: DataProduct = try await NetworkManager.shared.request(urlString: url)
            products = data.products
            collectionView.reloadData()
        } catch {
            print("Lỗi \(error)")
        }
    }
    
    @IBAction func didEditingChanged(_ sender: UITextField) {
        searchTimer?.invalidate()
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) {[weak self] _ in
            guard let query = self?.search.text, !query.isEmpty else {
                self?.products = []
                self?.collectionView.reloadData()
                return
            }
            
            Task {
                await self?.performSearch(query: query)
            }
        }
    }
    
}
extension SearchViewController: UICollectionViewDataSource, ProductCellDelegate {
    func didSelectProduct(_ product: Product) {
        let storyBoard = UIStoryboard(name: "DetailProduct", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "DetailProduct") as! DetailViewController
        vc.product = product
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyProductCell", for: indexPath) as! ProductCell
        let product = products[indexPath.row]
        cell.setProduct(product)
        cell.delegate = self
        cell.addButton = {
            CartManager.shared.addToCart(product: product)
            CartManager.shared.showToast(message: "Đã thêm vào giỏ hàng", view: self.view)
        }
        return cell
    }
}
