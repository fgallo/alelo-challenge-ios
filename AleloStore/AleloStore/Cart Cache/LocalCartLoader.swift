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

    public func load(completion: @escaping (CartCache.LoadResult) -> Void) {
        store.retrieve { result in
            switch result {
            case .empty:
                completion(.success([]))
            case let .found(cart):
                completion(.success(cart.toModels()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
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

private extension Array where Element == LocalCartItem {
    func toModels() -> [CartItem] {
        return map { CartItem(product: $0.product.toModel(), quantity: $0.quantity) }
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

private extension LocalProduct {
    func toModel() -> Product {
        return Product(
            name: self.name,
            regularPrice: self.regularPrice,
            salePrice: self.salePrice,
            onSale: self.onSale,
            imageURL: self.imageURL,
            sizes: self.sizes.toModels()
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

private extension Array where Element == LocalProductSize {
    func toModels() -> [ProductSize] {
        return map { ProductSize(
            size: $0.size,
            sku: $0.sku,
            available: $0.available
        )}
    }
}
