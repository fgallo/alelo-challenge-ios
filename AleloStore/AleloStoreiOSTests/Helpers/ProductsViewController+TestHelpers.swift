//
//  Created by Fernando Gallo on 06/06/23.
//

import UIKit
import AleloStoreiOS

extension ProductsViewController {
    func simulateUserInitiatedProductsReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateProductViewVisible(at index: Int) -> ProductCell? {
        return productView(at: index) as? ProductCell
    }
    
    func simulateProductViewNotVisible(at row: Int) {
        let view = simulateProductViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: productsSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    }
    
    func simulateProductViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: productsSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateProductViewNotNearVisible(at row: Int) {
        simulateProductViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: productsSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedProductViews() -> Int {
        return tableView.numberOfRows(inSection: productsSection)
    }
    
    func productView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: productsSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var productsSection: Int {
        return 0
    }
}
