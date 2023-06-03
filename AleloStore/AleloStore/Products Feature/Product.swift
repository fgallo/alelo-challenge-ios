//
//  Created by Fernando Gallo on 03/06/23.
//

import Foundation

public struct Product: Equatable {
    public let name: String
    public let regularPrice: String
    public let salePrice: String
    public let onSale: Bool
    public let imageURL: URL
    public let sizes: [ProductSize]
    
    public init(name: String, regularPrice: String, salePrice: String, onSale: Bool, imageURL: URL, sizes: [ProductSize]) {
        self.name = name
        self.regularPrice = regularPrice
        self.salePrice = salePrice
        self.onSale = onSale
        self.imageURL = imageURL
        self.sizes = sizes
    }
}
