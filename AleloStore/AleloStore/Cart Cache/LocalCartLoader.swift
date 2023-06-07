//
//  Created by Fernando Gallo on 07/06/23.
//

import Foundation

public final class LocalCartLoader {
    private let store: CartStore
    
    public init(store: CartStore) {
        self.store = store
    }
    
    public func save(_ cart: [CartItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedCart { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(cart, with: completion)
            }
        }
    }
    
    private func cache(_ cart: [CartItem], with completion: @escaping (Error?) -> Void) {
        store.insert(cart) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}

public protocol CartStore {
    func deleteCachedCart(completion: @escaping (Error?) -> Void)
    func insert(_ cart: [CartItem], completion: @escaping (Error?) -> Void)
}
