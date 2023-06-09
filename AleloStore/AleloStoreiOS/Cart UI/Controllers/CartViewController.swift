//
//  Created by Fernando Gallo on 08/06/23.
//

import UIKit

public final class CartViewController: UITableViewController {
    var viewModel: CartViewModel?
    var tableModel = [CartCellController]() {
        didSet { tableView.reloadData() }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        binding()
        loadCart()
    }
    
    private func loadCart() {
        viewModel?.loadCart()
    }
    
    private func binding() {
        //viewModel?.onLoadingStateChange = { [weak self] isLoading in
          //  isLoading ? self?.refreshControl?.beginRefreshing() : self?.refreshControl?.endRefreshing()
        //}
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
    
    private func cellController(forRowAt indexPath: IndexPath) -> CartCellController {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
    
}
