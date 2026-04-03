import UIKit

class CartController: UIViewController {

    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var checkOutBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func tapCheck(_ sender: Any) {
        CartManager.shared.setCheckOut()
        CartManager.shared.showToast(message: "Mua thành công", view: self.view)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "MyCartCell", bundle: nil), forCellReuseIdentifier: "MyCartCell")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateTotalUI()
    }
    
    func updateTotalUI() {
        let total = CartManager.shared.getTotal()
        totalLabel.text = "$" + String(format: "%.2f", total)
    }
}
extension CartController: UITableViewDelegate, UITableViewDataSource, ProductCellDelegate {
    func didSelectProduct(_ product: Product) {
        let storyBoard = UIStoryboard(name: "DetailProduct", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "DetailProduct") as! DetailViewController
        vc.product = product
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        CartManager.shared.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCartCell", for: indexPath) as? MyCartCell else {
            return UITableViewCell()
        }
        let product = CartManager.shared.products[indexPath.row]
        cell.onQuantityChanged = { [weak self] in
            self?.updateTotalUI()
        }
        cell.setProduct(product.product, quantity: product.quantity)
        cell.removeFromCart = {
            CartManager.shared.removeFromCart(product: product.product)
            self.tableView.reloadData()
            CartManager.shared.showToast(message: "Đã xoá khỏi giỏ hàng", view: self.view)
            self.updateTotalUI()
        }
        cell.delegate = self
        return cell
    }
    
}

