//
//  Created by Fernando Gallo on 07/06/23.
//

import Foundation

public struct LocalCartItem: Equatable, Codable {
    public let product: LocalProduct
    public var quantity: Int
    
    public init(product: LocalProduct, quantity: Int) {
        self.product = product
        self.quantity = quantity
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.product == rhs.product
    }
}
