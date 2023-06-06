//
//  Created by Fernando Gallo on 05/06/23.
//

import UIKit
import AleloStore

final public class ProductsViewController: UITableViewController {
    private var loader: ProductsLoader?
    private var tableModel = [Product]()
    
    public convenience init(loader: ProductsLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
            self?.tableModel = (try? result.get()) ?? []
            self?.tableView.reloadData()
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = ProductCell()
        cell.nameLabel.text = cellModel.name
        cell.regularPriceLabel.text = cellModel.regularPrice
        cell.salePriceLabel.text = cellModel.salePrice
        cell.sizesLabel.text = cellModel.sizes.first?.size
        cell.saleContainer.isHidden = !cellModel.onSale
        return cell
    }
}
