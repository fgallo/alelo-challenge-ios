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
    var onTotalPriceCalculated: ((String) -> Void)?
    
    func loadCart() {
        cartCache.load { [weak self] result in
            if let cart = try? result.get() {
                self?.onCartLoad?(cart)
                self?.calculateTotalPrice(cart)
            }
        }
    }
    
    func calculateTotalPrice(_ cart: [CartItem]) {
        let total = cart.reduce(0.0) { partialResult, cartItem in
            let price = cartItem.product.salePrice
            let formattedPrice = price.replacingOccurrences(of: "R$ ", with: "").replacingOccurrences(of: ",", with: ".")
            
            if let priceDouble = Double(formattedPrice) {
                return partialResult + Double(cartItem.quantity) * priceDouble
            }
            
            return partialResult
        }
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        onTotalPriceCalculated?(formatter.string(from: total as NSNumber) ?? "")
    }
}
