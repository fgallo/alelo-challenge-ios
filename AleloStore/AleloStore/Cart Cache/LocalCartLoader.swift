//
//  Created by Fernando Gallo on 07/06/23.
//

import Foundation

public final class LocalCartLoader: CartCache {
    private let store: CartStore
    
    public init(store: CartStore) {
        self.store = store
    }
    
    public func save(_ cart: [CartItem], completion: @escaping (CartCache.SaveResult) -> Void) {
        store.deleteCachedCart { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(cart, with: completion)
            }
        }
    }

    public func load() {
        store.retrieve()
    }
    
    private func cache(_ cart: [CartItem], with completion: @escaping (CartCache.SaveResult) -> Void) {
        store.insert(cart.toLocal()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}

private extension Array where Element == CartItem {
    func toLocal() -> [LocalCartItem] {
        return map { LocalCartItem(product: $0.product.toLocal(), quantity: $0.quantity) }
    }
}

private extension Product {
    func toLocal() -> LocalProduct {
        return LocalProduct(
            name: self.name,
            regularPrice: self.regularPrice,
            salePrice: self.salePrice,
            onSale: self.onSale,
            imageURL: self.imageURL,
            sizes: self.sizes.toLocal()
        )
    }
}

private extension Array where Element == ProductSize {
    func toLocal() -> [LocalProductSize] {
        return map { LocalProductSize(
            size: $0.size,
            sku: $0.sku,
            available: $0.available
        )}
    }
}
