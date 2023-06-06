//
//  Created by Fernando Gallo on 06/06/23.
//

import Foundation
import AleloStore

final public class ProductsViewModel {
    private let productsLoader: ProductsLoader?
    
    init(productsLoader: ProductsLoader?) {
        self.productsLoader = productsLoader
    }
    
    private enum State {
        case pending
        case loading
        case loaded([Product])
        case failed
    }
    
    private var state = State.pending {
        didSet { onChange?(self) }
    }
    
    var onChange: ((ProductsViewModel) -> Void)?
    
    var isLoading: Bool {
        switch state {
        case .loading: return true
        case .pending, .loaded, .failed: return false
        }
    }
    
    var products: [Product]? {
        switch state {
        case let .loaded(products): return products
        case .pending, .loading, .failed: return nil
        }
    }
    
    func loadProducts() {
        state = .loading
        productsLoader?.load { [weak self] result in
            if let products = try? result.get() {
                self?.state = .loaded(products)
            } else {
                self?.state = .failed
            }
        }
    }
}
