//
//  Created by Fernando Gallo on 08/06/23.
//

import Foundation
import AleloStore

final public class CartViewModel {
    private let cartCache: CartCache
    
    init(cartCache: CartCache) {
        self.cartCache = cartCache
    }

    var onCartLoad: (([CartItem]) -> Void)?
    
    func loadCart() {
        cartCache.load { [weak self] result in
            if let cart = try? result.get() {
                self?.onCartLoad?(cart)
            }
        }
    }
}
