//
//  Created by Fernando Gallo on 05/06/23.
//

import UIKit
import AleloStore

final public class ProductsViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var productsLoader: ProductsLoader?
    private var imageLoader: ProductImageDataLoader?
    private var tableModel = [Product]()
    private var tasks = [IndexPath: ProductImageDataLoaderTask]()
    
    public convenience init(productsLoader: ProductsLoader, imageLoader: ProductImageDataLoader) {
        self.init()
        self.productsLoader = productsLoader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        tableView.prefetchDataSource = self
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
        cell.productImageView.image = nil
        cell.imageContainer.isShimmering = true
        if let url = cellModel.imageURL {
            tasks[indexPath] = imageLoader?.loadImageData(from: url) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.productImageView.image = image 
                cell?.imageContainer.isShimmering = false
            }
        }
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellModel = tableModel[indexPath.row]
            if let url = cellModel.imageURL {
                tasks[indexPath] = imageLoader?.loadImageData(from: url) { _ in }
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
    
    private func cancelTask(forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
    
}
