//
//  Created by Fernando Gallo on 06/06/23.
//

import Foundation

public struct CartItem: Equatable {
    public let product: Product
    public var quantity: Int
    
    public init(product: Product, quantity: Int) {
        self.product = product
        self.quantity = quantity
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.product == rhs.product
    }
}
