//
//  Created by Fernando Gallo on 05/06/23.
//

import UIKit

final public class ProductsViewController: UITableViewController, UITableViewDataSourcePrefetching {
    var viewModel: ProductsViewModel?
    var tableModel = [ProductCellController]() {
        didSet { tableView.reloadData() }
    }
    var selection: (() -> Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        binding()
        refresh()
    }
    
    @IBAction func refresh() {
        viewModel?.loadProducts()
    }
    
    @objc func saveCart() {
        let cart = tableModel
            .map { $0.viewModel.toCartItem() }
            .filter { $0.quantity > 0 }
        
        viewModel?.saveCart(cart)
    }
    
    private func binding() {
        viewModel?.onLoadingStateChange = { [weak self] isLoading in
            isLoading ? self?.refreshControl?.beginRefreshing() : self?.refreshControl?.endRefreshing()
        }
        
        viewModel?.onSaveCart = { [weak self] error in
            guard error == nil else {
                return
            }
            
            self?.selection?()
        }
    }
     
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view(in: tableView)
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
