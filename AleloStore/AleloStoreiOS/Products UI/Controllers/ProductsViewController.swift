//
//  Created by Fernando Gallo on 05/06/23.
//

import UIKit

final public class ProductsViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var viewModel: ProductsViewModel?
    private var imageLoader: ProductImageDataLoader?
    private var tableModel = [ProductCellController]()
    
    public convenience init(viewModel: ProductsViewModel, imageLoader: ProductImageDataLoader) {
        self.init()
        self.viewModel = viewModel
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        tableView.prefetchDataSource = self
        binding()
        load()
    }
    
    @objc private func load() {
        viewModel?.loadProducts()
    }
    
    private func binding() {
        viewModel?.onChange = { [weak self] viewModel in
            if viewModel.isLoading {
                self?.refreshControl?.beginRefreshing()
            } else {
                self?.refreshControl?.endRefreshing()
            }
            
            if let products = viewModel.products {
                self?.tableModel = products.map { model in
                    ProductCellController(model: model, imageLoader: self!.imageLoader!)
                }
                self?.tableView.reloadData()
            }
        }
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> ProductCellController {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
    
}
