//
//  Created by Fernando Gallo on 05/06/23.
//

import UIKit
import AleloStore

final public class ProductsViewController: UITableViewController {
    private var loader: ProductsLoader?
    
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
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}
