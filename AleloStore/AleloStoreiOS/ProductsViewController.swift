//
//  Created by Fernando Gallo on 05/06/23.
//

import UIKit
import AleloStore

public protocol ProductImageDataLoader {
    func loadImageData(from url: URL)
}

final public class ProductsViewController: UITableViewController {
    private var productsLoader: ProductsLoader?
    private var imageLoader: ProductImageDataLoader?
    private var tableModel = [Product]()
    
    public convenience init(productsLoader: ProductsLoader, imageLoader: ProductImageDataLoader) {
        self.init()
        self.productsLoader = productsLoader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        productsLoader?.load { [weak self] result in
            if let products = try? result.get() {
                self?.tableModel = products
                self?.tableView.reloadData()
            }
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
        if let url = cellModel.imageURL {
            imageLoader?.loadImageData(from: url)
        }
        return cell
    }
}
