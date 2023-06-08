//
//  Created by Fernando Gallo on 06/06/23.
//

import Foundation
import AleloStore

final public class ProductsViewModel {
    private let productsLoader: ProductsLoader
    private let cartCache: CartCache
    
    init(productsLoader: ProductsLoader, cartCache: CartCache) {
        self.productsLoader = productsLoader
        self.cartCache = cartCache
    }
    
    var onLoadingStateChange: ((Bool) -> Void)?
    var onProductsLoad: (([Product]) -> Void)?
    var onSaveCart: ((Error?) -> Void)?
    
    func loadProducts() {
        onLoadingStateChange?(true)
        productsLoader.load { [weak self] result in
            if let products = try? result.get() {
                self?.onProductsLoad?(products)
            }
            self?.onLoadingStateChange?(false)
        }
    }
    
    func saveCart() {
        cartCache.save([]) { [weak self] error in
            self?.onSaveCart?(error)
        }
    }
}
