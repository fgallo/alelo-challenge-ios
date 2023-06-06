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
    
    var onLoadingStateChange: ((Bool) -> Void)?
    var onProductsLoad: (([Product]) -> Void)?
    
    func loadProducts() {
        onLoadingStateChange?(true)
        productsLoader?.load { [weak self] result in
            if let products = try? result.get() {
                self?.onProductsLoad?(products)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
