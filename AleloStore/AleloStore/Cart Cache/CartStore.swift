//
//  Created by Fernando Gallo on 07/06/23.
//

import Foundation

public protocol CartStore {
    func deleteCachedCart(completion: @escaping (Error?) -> Void)
    func insert(_ cart: [LocalCartItem], completion: @escaping (Error?) -> Void)
}

public struct LocalCartItem: Equatable {
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

public struct LocalProduct: Equatable {
    public let name: String
    public let regularPrice: String
    public let salePrice: String
    public let onSale: Bool
    public let imageURL: URL?
    public let sizes: [LocalProductSize]
    
    public init(name: String, regularPrice: String, salePrice: String, onSale: Bool, imageURL: URL?, sizes: [LocalProductSize]) {
        self.name = name
        self.regularPrice = regularPrice
        self.salePrice = salePrice
        self.onSale = onSale
        self.imageURL = imageURL
        self.sizes = sizes
    }
}

public struct LocalProductSize: Equatable {
    public let size: String
    public let sku: String
    public let available: Bool
    
    public init(size: String, sku: String, available: Bool) {
        self.size = size
        self.sku = sku
        self.available = available
    }
}
